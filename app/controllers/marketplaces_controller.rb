class MarketplacesController < ApplicationController

  def show
    @products = Product.where(status: 2).desc(:created_at)
  end

  def featured
    @products = Product.where(status: 2, featured_on_marketplace: true).desc(:created_at)
    render :action => :show
  end

  def fresh
    @products = Product.where(status: 0).desc(:created_at)
    render :action => :show
  end

end