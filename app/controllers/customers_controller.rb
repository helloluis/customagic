class CustomersController < ApplicationController

  before_filter :set_shop
  before_filter :authenticate_user!
  before_filter :authorize_account_user!

  def index; end
  def show; end
  protected
    def set_shop
      @current_shop = Shop.find(params[:shop_id])
    end
end