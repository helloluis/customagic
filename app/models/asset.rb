class Asset
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :shop
  belongs_to :product

  field :asset_type,    type: String,   default: "text"
  field :coordinates,   type: Array,    default: [0,0,1] # x, y, z
  field :filesize,      type: Integer   
  field :width,         type: Integer,  default: 250 
  field :height,        type: Integer,  default: 100
  field :color,         type: String,   default: "#000000"
  field :bg_color,      type: String,   default: "transparent"
  field :font,          type: String,   default: "Helvetica"
  field :font_size,     type: String,   default: "36px"
  field :alignment,     type: String,   default: "center"
  field :product_side,  type: Integer,  default: 0  # what side of the product is this asset on? a shirt will have two sides (0 = front, 1 = back)
  field :content,       type: String,   default: "Text"

  # CARRIERWAVE ATTACHMENT 
  mount_uploader :attachment, AssetAttachment

  def __id
    _id.to_s
  end

  def get_dimensions_and_filesize
    
    self.filesize     = attachment.file.size

    return true unless asset_type=='photo'

    begin
      image = MiniMagick::Image.open(attachment.current_path)
      self.width  = [image[:width],50].max
      self.height = [image[:height],50].max
      
    rescue Exception => e
      logger.info "!! ERROR: #{attachment.current_path} #{e.inspect} !!"
    end
  end

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
  
end