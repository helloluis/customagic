class EarningsController < ApplicationController

  include ApplicationHelper

  before_filter :set_shop

  before_filter :authenticate_user!
  before_filter :authorize_account_user!

  def index

  end

  protected
    
    def set_shop
      @current_shop = Shop.find(params[:shop_id]) if params[:shop_id]
    end

end