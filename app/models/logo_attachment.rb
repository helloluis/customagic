class LogoAttachment < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog
  
  version :thumb, :if => :image? do
    process :resize_to_fit => [100, 100]
  end

  def store_dir
    "uploads/shops/attachment/#{model.id}"
  end
  
  def asset
    model
  end

  def original_filename
    url ? File.basename( url ) : ""
  end

  protected 
  
  def image?(new_file)
    new_file.content_type=~/png|jpg|jpeg|gif/i
  end
end