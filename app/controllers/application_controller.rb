class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def aws_bucket
    Aws::S3::Resource.new( region: 'us-east-2', access_key_id: ENV[ 'AWS_ACCESS_KEY_ID' ], secret_access_key: ENV[ 'AWS_SECRET_ACCESS_KEY' ] )
  end
end
