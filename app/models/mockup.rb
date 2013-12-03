class Mockup 

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :shop
  belongs_to :product

  field :width,       type: Integer # in px
  field :height,      type: Integer
  field :dpi_target,  type: Integer # dots per cm 

  attr_accessible :width, :height, :dpi_target

  after_create :generate_image

  mount_uploader :attachment, MockupAttachment

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

    return false if self.product && (self.product.final_art_html.blank? || self.product.mockup_html.blank?)
    
    opts = {:transparent => true, width: width, height: height, "crop-w".to_sym => width, "crop-h".to_sym => height}

    kit = IMGKit.new(self.product.mockup_html, opts)
    
    img = Tempfile.new(["#{self.product._id}_#{Time.now.to_i}",'.png'], Rails.root.join("tmp"), :encoding => 'ascii-8bit')
    
    img.write(kit.to_img(:png))

    img.flush

    self.attachment = File.open(img.path)

    self.save
    
    img.unlink

  end

end