class Mockup < FinalArt

  def generate_image

    return false if self.product && (self.product.final_art_html.blank? || self.product.mockup_html.blank?)
    
    opts = {:transparent => true, width: width, height: height, "crop-w".to_sym => width, "crop-h".to_sym => height}
    
    kit = IMGKit.new(self.product.mockup_html, opts)
    
    img = Tempfile.new(["#{self.product._id}_#{Time.now.to_i}",'png'], Rails.root.join("tmp"), :encoding => 'ascii-8bit')
    
    img.write(kit.to_img(:png))

    img.flush

    self.attachment = File.open(img.path)

    self.save
    
    img.unlink

  end

end