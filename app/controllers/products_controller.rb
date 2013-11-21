class ProductsController < ApplicationController

  before_filter :set_shop
  before_filter :set_product, only: [ :edit, :update, :delete, :show ]

  def index

  end

  def show

  end

  def new
    if @product = @shop.products.create(name: "Awesome Shirt")
      redirect_to "/#{@shop.slug}/products/#{@product.slug}/edit"
    else
      flash[:alert] = "We couldn't add a new product to your shop."
      redirect_to "/#{@shop.slug}"
    end
  end

  def create

  end

  def edit
    @assets = @product.assets
  end

  def update

  end

  def delete

  end

  protected
    def set_shop
      @shop = Shop.find(params[:shop_id])
    end

    def set_product
      unless @product = @shop.products.find(params[:id])
        flash[:alert] = "We couldn't find that item."
        redirect_to "/#{@shop.slug}"
      end
    end
end