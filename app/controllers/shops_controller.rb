class ShopsController < ApplicationController

  before_filter :set_shop, except: [:index]

  def index;end

  def show;end

  protected

    def set_shop
      @current_shop = @shop = Shop.find(params[:id])
    end

end