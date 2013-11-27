class ShopsController < ApplicationController

  before_filter :set_shop, except: [:index]

  def index;end

  def show
    @products = @current_shop.products.desc(:availability_start)
    @edit_mode = true if is_owner?(@current_shop)
  end

  protected

    def set_shop
      @current_shop = @shop = Shop.find(params[:id])
    end

end