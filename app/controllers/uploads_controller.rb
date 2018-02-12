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
    client = Slack::Web::Client.new
    client.chat_postMessage( channel: '#it-requests', text: 'Please check new optimized images', username: "Ekaterina Ovodova" )
    redirect_to root_path
  end
end
