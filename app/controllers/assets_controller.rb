class AssetsController < ApplicationController

  # TODO: Needs authentication and permission checks
  before_filter :set_shop
  before_filter :set_product, :only => [ :create, :create_photo ]

  respond_to :html, :json

  def create
    @asset = Asset.new({ shop: @shop, product: @product })
    @asset.save
    respond_to do |format|
      if @asset.save
        format.json { render :json => @asset.as_json(methods: [:__id]) }
      else
        format.json do 
          render :json => { :error => @asset.errors.full_messages.join("") }, :status => :unprocessable_entity
        end
      end
    end
  end

  def create_photo
    # logger.info "!! #{current_user.inspect} !!"
    if params[:attachments]
      @image = @shop.images.new({ attachment: params[:attachments].first })
    elsif params[:image]
      @image = @shop.images.new(params[:image])
    end
    
    if @image.get_dimensions_and_filesize && @image.save

      @asset = @shop.assets.create({ 
        asset_type: "photo", 
        product: Product.find(params[:product_id]), 
        image: @image })
      
      respond_to do |format|
        format.html { render :inline => "<textarea>#{[@asset.to_json.html_safe, @image.to_json.html_safe]}</textarea>" }
        format.json { render :json => [@asset.to_json.html_safe, @image.to_json.html_safe] }
      end

    else
      respond_to do |format|
        format.html { render :inline => "<textarea>#{{:error => @image.errors.full_messages}.to_json.html_safe}</textarea>" }
        format.json do 
          render :json => { :error => @image.errors.full_messages.join("") }, :status => :unprocessable_entity
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

  def update
    if @asset = @shop.assets.find(params[:id])
      @asset.update_attributes(params[:asset])
      respond_to do |format|
        format.json { render :json => @asset }
      end
    else
      respond_to do |format|
        format.json { render :json => { errors: "Couldn't find that asset (#{params[:id]})" } }
      end
    end
  end

  def destroy
    if @asset = @shop.assets.find(params[:id])
      @asset.destroy
      respond_to do |format|
        format.json { render :json => { success: true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { errors: true } }
      end
    end
  end

  protected

    def set_shop
      @current_shop = @shop = Shop.find(params[:shop_id])
    end

    def set_product
      unless @product = Product.find(params[:product_id])
        respond_to do |format|
          format.json do 
            render :inline => "We couldn't find a product to add that asset to.", :status => 422 and return 
          end
        end
      end
    end

end