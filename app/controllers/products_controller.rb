class ProductsController < ApplicationController

  before_filter :set_shop
  before_filter :set_product, only: [ :edit, :edit_info, :update, :delete, :show ]
  before_filter :authenticate_user!, except: [ :show ]
  before_filter :authorize_account_user!

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
  end

  def edit_info

  end

  def update
    if @product.update_attributes(params[:product].permit!)
      @product.create_final_art if params[:publish]
      respond_to do |format|
        format.json { render :json => @product }
      end
    end
  end

  def update_sales_information
    if @product.update_attributes(params[:product].permit!)
      @product.update_sales_information!
      respond_to do |format|
        format.json { render :json => @product }
      end
    end
  end

  def delete

  end

  protected
    def set_shop
      @current_shop = Shop.find(params[:shop_id])
    end

    def set_product
      unless @product = @current_shop.products.find(params[:id])
        flash[:alert] = "We couldn't find that item."
        redirect_to "/#{@current_shop.slug}"
      end
    end
end