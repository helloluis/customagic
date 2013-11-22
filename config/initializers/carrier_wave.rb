# CarrierWave.configure do |config|
#   config.storage = :s3
#   config.s3_access_key_id = App.s3.access_key_id
#   config.s3_secret_access_key = App.s3.secret_access_key
#   config.s3_bucket = App.s3.bucket_name
# end


CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                 # required
    :aws_access_key_id      => App.s3.access_key_id,          # required
    :aws_secret_access_key  => App.s3.secret_access_key         # required
  }
  config.fog_directory  = App.s3.bucket_name                     # required
  # config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
  # config.fog_public     = false                                   # optional, defaults to true
  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# put this in config/initializers/carrierwave.rb
module CarrierWave
  module MiniMagick
    def quality(percentage=75)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end