class LandingController < ApplicationController

  include ApplicationHelper

  respond_to :json, :html

  def index
    @products = Product.where(status:2).desc(:created_at).limit(10)
  end
  
end