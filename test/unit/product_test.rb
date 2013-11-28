require 'test_helper'
 
class ProductTest < ActiveSupport::TestCase

  include Mongoid::Matchers

  def setup
    @shop = Shop.new(time_zone: "Singapore")
    @product = @shop.products.new(availability_start: 3.days.from_now)
    @available_product = @shop.products.new(availability_start: 3.days.ago, sales_goal: 50, num_orders: 5, status: 2)
    @available_product2 = @shop.products.new(availability_start: 3.days.ago, sales_goal: 50, num_orders: 55, status: 2)
    @unavailable_product = @shop.products.new(availability_start: 30.days.ago, campaign_length: 20, sales_goal: 50, num_orders: 55, status: 2)
  end

  test "should have an availability_end after availability_start" do
    assert @product.availability_end>@product.availability_start
  end

  test "should be orderable" do
    assert @available_product.is_orderable?
  end

  test "shouldn't be orderable yet" do
    assert !@product.is_orderable?
  end

  test "should be available at group price" do
    assert @available_product.is_group_orderable?
  end

  test "shouldn't be available at group price" do
    assert !@unavailable_product.is_group_orderable?
  end

  test "should be available at group price even when orders exceed goal" do
    assert @available_product2.is_group_orderable?
  end

  # test "buy_now_price should be greater than base_price" do
  #   assert @available_product.buy_now_price>@available_product.base_price
  # end

end