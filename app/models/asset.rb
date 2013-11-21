class Asset
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :shop
  belongs_to :product
  
  field :asset_type,    type: String,   default: "text"
  field :coordinates,   type: Array,    default: [0,0,1] # x, y, z
  field :width,         type: Integer,  default: 300 
  field :height,        type: Integer,  default: 100
  field :color,         type: String,   default: "#000000"
  field :bg_color,      type: String,   default: "transparent"
  field :font,          type: String,   default: "Helvetica"
  field :font_size,     type: String,   default: "36px"
  field :alignment,     type: String,   default: "center"
  
  field :content

  def __id
    _id.to_s
  end

end