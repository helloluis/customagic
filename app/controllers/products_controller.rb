class ProductsController < ApplicationController

  def index

  end

  def show

  end

  def new
    @product = @shop.products.new
  end

  def create

  end

  def edit

  end

  def update

  end

  def delete

  end

  protected
    def set_shop
      @shop = Shop.find(params[:shop_id])
    end
end