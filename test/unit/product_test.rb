require 'test_helper'
 
class ProductTest < ActiveSupport::TestCase

  include Mongoid::Matchers

  def setup
    Shop.destroy_all
    Product.destroy_all
    Asset.destroy_all
  end

  test "should create first asset" do 
    @shop = Shop.create(name: "New Shop #{rand(1000)}")
    @new_product = @shop.products.create(name: "Awesome Shirt #{rand(1000)}")
    assert @new_product.assets.any?, "#{@new_product.assets.length} assets created"
  end

  test "should be orderable" do
    @shop = Shop.create(name: "New Shop #{rand(1000)}")
    @available_product = @shop.products.new(status: 2)
    assert @available_product.is_orderable?
  end

  test "shouldn't be orderable yet" do
    @shop = Shop.create(name: "New Shop #{rand(1000)}")
    @unavailable_product = @shop.products.new
    assert !@unavailable_product.is_orderable?
  end

  test "updating sales_info should create price_variants array" do
    @shop = Shop.create(name: "New Shop #{rand(1000)}")
    @product = @shop.products.create(name: "Awesome Shirt #{rand(1000)}", :buy_now_price => 300.0)
    @product.update_sales_information!
    assert @product.price_variants.map{|pv|pv[:primary]} == @product.product_style_object.sizes, @product.price_variants.map{|pv|pv[:primary]}.inspect
  end

  test "updating sales_info should initialize base_price" do
    @shop = Shop.create(name: "New Shop #{rand(1000)}")
    @product = @shop.products.create(name: "Awesome Shirt #{rand(1000)}", :buy_now_price => 300.0)
    @product.update_sales_information!
    assert @product.base_price == @product.product_sub_style_object.prices.first.last, @product.base_price.to_s
  end

  # test "should have an availability_end after availability_start" do
  #   assert @product.availability_end>@product.availability_start
  # end

  # test "should be available at group price" do
  #   assert @available_product.is_group_orderable?
  # end

  # test "shouldn't be available at group price" do
  #   assert !@unavailable_product.is_group_orderable?
  # end

  # test "should be available at group price even when orders exceed goal" do
  #   assert @available_product2.is_group_orderable?
  # end

  # test "buy_now_price should be twice the group_price" do 
  #   assert @pricey_product.buy_now_price==@pricey_product.group_price*2
  # end

  # test "buy_now_price should be greater than base_price" do
  #   assert @available_product.buy_now_price>@available_product.base_price
  # end

end