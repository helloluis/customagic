class CannedImage < Image

  field :name
  field :artist,        type: String,  default: "The Internet"
  field :category_slug, type: String,  default: "meme"
  field :featured,      type: Boolean, default: true
  field :visible,       type: Boolean, default: true
  field :partner,       type: String,  default: "inkify"

  mount_uploader :attachment, CannedImageAttachment

end