class AssetsController < ApplicationController

  # TODO: Needs authentication and permission checks
  before_filter :set_shop
  # before_filter :set_product

  def create

  end

  def create_photo
    # logger.info "!! #{current_user.inspect} !!"
    @asset = Asset.new({ shop: @shop, asset_type: "photo", product: Product.find(params[:product_id]) }.merge(:attachment => params[:attachments].first))
    
    respond_to do |format|
      if @asset.get_dimensions_and_filesize && @asset.save
        @asset.reload
        format.html { render :inline => "<textarea>#{@asset.to_json(:methods => [:__id, :attachment_filename, :attachment_medium_url, :attachment_url, :attachment_thumb_url]).html_safe}</textarea>" }
        format.json { render :json => @asset }
      else
        format.html { render :inline => "<textarea>#{{:error => @asset.errors.full_messages}.to_json.html_safe}</textarea>" }
        format.json do 
          render :json => { :error => @asset.errors.full_messages.join("") }, :status => :unprocessable_entity
        end
      end
    end
    rescue OpenURI::HTTPError
      respond_to do |format|
        format.html { render :inline => "<textarea>#{{:error => 'We couldn\'t find an image at that location.'}.to_json.html_safe}</textarea>" }
        format.json { render :json => { :error => "We couldn't find an image at that location." }, :status => :unprocessable_entity }
      end
    rescue CarrierWave::ProcessingError
      respond_to do |format|
        format.html { render :inline => "<textarea>#{{:error => 'Are you sure that\'s an image?'}.to_json.html_safe}</textarea>" }
        format.json { render :json => { :error => "Are you sure that's an image?" }, :status => :unprocessable_entity }
      end
  end

  def show

  end

  protected

    def set_shop
      @shop = Shop.find(params[:shop_id])
      # if logged_in?
      #   @shop = current_user.shop 
      # else
      #   render :inline => "Sorry, that won't work.", :status => 422 and return
      # end
    end

end