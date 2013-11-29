class Asset
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :shop
  belongs_to :product

  field :asset_type,    type: String,   default: "text"
  field :coordinates,   type: Array,    default: [0,0,1] # x, y, z
  field :image_id
  # field :filesize,      type: Integer   
  field :width,         type: Integer,  default: 250 
  field :height,        type: Integer,  default: 100
  field :color,         type: String,   default: "#000000"
  field :bg_color,      type: String,   default: ""
  field :font_family,   type: String,   default: "Helvetica"
  field :font_size,     type: String,   default: "36px"
  field :alignment,     type: String,   default: "center"
  field :product_side,  type: Integer,  default: 0  # what side of the product is this asset on? a shirt will have two sides (0 = front, 1 = back)
  field :content,       type: String,   default: "Text"

  # # CARRIERWAVE ATTACHMENT 
  # mount_uploader :attachment, AssetAttachment

  def __id
    _id.to_s
  end

  def attachment_filename
    image && image.attachment ? image.attachment.original_filename : ""
  end

  def attachment_url
    image && image.attachment ? image.attachment.url : ""
  end

  def attachment_thumb_url
    image && image.attachment ? image.attachment.thumb.url : ""
  end

  def attachment_medium_url
    image && image.attachment ? image.attachment.medium.url : ""
  end
  
  def image=(new_image)
    self.write_attributes(
      image_id: new_image._id,
      width: new_image.width,
      height: new_image.height
      )
    new_image.asset_ids.push(self._id).uniq
    new_image.save
  end

  def image
    if self.image_id
      self.shop.images.find(self.image_id)
    else
      false
    end
  end

  def as_json(options = {})
    super(options.reverse_merge(:methods => [:__id, :attachment_filename, :attachment_medium_url, :attachment_url, :attachment_thumb_url]))
  end
  
end