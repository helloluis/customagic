class FinalArt

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :shop
  belongs_to :product

  field :width,       type: Integer # in px
  field :height,      type: Integer
  field :target_dpi,  type: Integer # dots per cm 

  after_create :generate_image

  mount_uploader :attachment, FinalArtAttachment

  def attachment_filename
    attachment ? attachment.original_filename : ""
  end

  def attachment_url
    attachment ? attachment.url : ""
  end

  def attachment_thumb_url
    attachment ? attachment.thumb.url : ""
  end

  def attachment_medium_url
    attachment ? attachment.medium.url : ""
  end

  def generate_image

    kit = IMGKit.new(self.product.raw_html, :quality => 100, :width => width, :height => height)
    
    file = kit.to_file(Rails.root.join("tmp","#{self.product._id}_#{Time.now.to_i}.jpg"))

    self.attachment = File.open(file)

    img = MiniMagick::Image.open(self.attachment.current_path)

    self.write_attributes(width: img[:width], height: img[:height])

    self.save

  end

end