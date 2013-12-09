class LandingController < ApplicationController

  include ApplicationHelper

  respond_to :json, :html

  def index
    @available_products = Product.where(status:2).desc(:created_at).limit(10)
    @pending_products   = Product.where(status:0).desc(:created_at)
  end
  
end