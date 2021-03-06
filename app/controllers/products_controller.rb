class ProductsController < ApplicationController

  include ApplicationHelper

  before_filter :set_shop

  before_filter :set_product, only: [ :edit, :edit_info, :update, :update_info, :ready, :destroy, :show ]
  before_filter :authenticate_user!, except: [ :show ]
  before_filter :authorize_account_user!

  before_filter :check_product_visibility, only: [ :show ]

  respond_to :html, :json

  def index

  end

  def show

  end

  def new
    if @product = @current_shop.products.create(name: "Awesome Shirt")
      redirect_to "/#{@current_shop.slug}/products/#{@product.slug}/edit"
    else
      flash[:alert] = "We couldn't add a new product to your shop."
      redirect_to "/#{@current_shop.slug}"
    end
  end

  def create

  end

  def edit
    @assets = @product.assets
    @images = @shop.images
    render :layout => "editor"
  end

  def edit_info
    render :layout => "editor"
  end

  def ready
    render :layout => "editor"
  end

  def update
    if @product.update_attributes(params[:product])
      @product.generate_art!
      respond_to do |format|
        format.json { render :json => @product }
      end
    end
  end

  def update_info
    if @product.update_attributes(params[:product])
      @product.update_sales_information!
      respond_to do |format|
        format.html { redirect_to :action => :ready }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = "Your product information couldn't be saved!"
          render :layout => "editor", :action => :edit_info
        end
      end
    end
  end

  def make_ready
    @product.update_attributes(status: 2)
    respond_to do |format|
      flash[:notice] = "Your work is now visible in the marketplace!"
      redirect_to product_path(@product)
    end
  end

  def destroy
    @product.destroy
    @product.assets.destroy_all
    respond_to do |format|
      format.json { render :inline => { :success => true } }
    end
  end

  protected
    def set_shop
      @current_shop = Shop.find(params[:shop_id]) if params[:shop_id]
    end

    def set_product
      unless @product = Product.find(params[:id])
        flash[:alert] = "We couldn't find that item."
        redirect_to "/#{@current_shop.slug}"
      end
      @current_product = @product
      @current_shop ||= @product.shop
      @shop = @current_shop
    end

    def check_product_visibility
      if @product.status<=1 && !is_owner?(@current_shop)
        flash[:alert] = "This product isn't available yet."
        redirect_to "/#{@current_shop.slug}"
      end
    end
end