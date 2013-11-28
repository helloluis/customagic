class ShopsController < ApplicationController

  include ApplicationHelper
  before_filter :set_shop, except: [:index]

  def index;end

  def show
    @products = @current_shop.products.desc(:availability_start)
    @edit_mode = true if is_owner?(@current_shop)
  end

  def update
    if @shop.update_attributes(params[:shop])
      flash[:notice] = "Your shop settings have been successfully saved."
      redirect_to :action => :show
    else
      flash[:error] = "Your shop settings couldn't be saved."
      render :action => :edit
    end
  end

  protected

    def set_shop
      @current_shop = @shop = Shop.find(params[:id])
    end

end