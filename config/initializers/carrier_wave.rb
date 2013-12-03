# CarrierWave.configure do |config|
#   config.storage = :s3
#   config.s3_access_key_id = App.s3.access_key_id
#   config.s3_secret_access_key = App.s3.secret_access_key
#   config.s3_bucket = App.s3.bucket_name
# end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                 # required
      :aws_access_key_id      => App.s3.access_key_id,          # required
      :aws_secret_access_key  => App.s3.secret_access_key         # required
    }
    config.fog_directory  = App.s3.bucket_name                     # required
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
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