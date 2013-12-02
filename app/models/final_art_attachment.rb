class FinalArtAttachment < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick
  
  storage Rails.env.production? ? :fog : :file

  version :thumb do
    process :resize_to_fit => [200, 200]
  end
  
  version :medium do
    process :resize_to_fit => [600, 600]
  end  

  def store_dir
    "uploads/final_arts/attachment/#{model.id}"
  end
  
  def asset
    model
  end

  def original_filename
    url ? File.basename( url ) : ""
  end

end
