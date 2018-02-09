class UploadsController < ApplicationController
  def create
    if request.xhr?
      file_attributes = params[ :file ]
      file = open( file_attributes )
      IO.copy_stream( file, file_attributes.original_filename )

      MiniMagick::Tool::Convert.new do |convert|
        convert << file_attributes.original_filename
        convert.merge! [ "-sampling-factor", "4:2:0", "-strip", "-quality", "85", "-interlace", "JPEG", "-colorspace", "RGB" ]
        convert << "min-#{ file_attributes.original_filename }"
      end

      bucket = 'marketing-imaging'
      obj = aws_bucket.bucket( bucket ).object( "min-#{ file_attributes.original_filename }" )
      new_file = open( Rails.root.join( "min-#{ file_attributes.original_filename }" ) )
      uploaded_file = obj.upload_file( new_file )
      Upload.create( file_part: "https://s3.us-east-2.amazonaws.com/#{ bucket }/min-#{ file_attributes.original_filename }" )
      FileUtils.rm( Rails.root.join( "min-#{ file_attributes.original_filename }" ) )
      FileUtils.rm( Rails.root.join( "#{ file_attributes.original_filename }" ) )
      render json: { message: "success" }, :status => 200
    end
  end

  def download_zip
    require 'zip'
    bucket = aws_bucket.bucket( "marketing-imaging" )
    files = Upload.all.map { | file | file.file_part.split( "/" )[ -1 ] }

    files.each do | file_name |
      file_obj = bucket.object( file_name )
      file_obj.get( response_target: Rails.root.join( "public/tmp/#{ file_name }" ) )
    end

    sleep 5
    FileUtils.rm( Rails.root.join( "public/tmp/optimized.zip" ) ) if File.exist?( Rails.root.join( "public/tmp/optimized.zip" ) )

    Zip::File.open( Rails.root.join( "public/tmp/optimized.zip" ), Zip::File::CREATE ) do | zipfile |
      files.each do | filename |
        zipfile.add( filename, Rails.root.join( "public/tmp/#{ filename }" ) )
      end
    end

    Upload.destroy_all
    files.each { | filename | FileUtils.rm( Rails.root.join( "public/tmp/#{ filename }" ) ) }
    send_file Rails.root.join( "public/tmp/optimized.zip" )
  end
end
