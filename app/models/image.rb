class Image

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :shop

  field :filesize,  type: Integer
  field :width,     type: Integer
  field :height,    type: Integer
  field :asset_ids, type: Array,   default: []

  mount_uploader :attachment, ImageAttachment


  def get_dimensions_and_filesize
    self.filesize     = attachment.file.size
    begin
      img = MiniMagick::Image.open(attachment.current_path)
      self.width  = [img[:width],50].max
      self.height = [img[:height],50].max
      
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

  def __id
    _id.to_s
  end

  def as_json(options = {})
    super(options.reverse_merge(:methods => [:__id, :attachment_filename, :attachment_medium_url, :attachment_url, :attachment_thumb_url]))
  end

end