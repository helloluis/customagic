require 'test_helper'
 
class ProductTest < ActiveSupport::TestCase

  include Mongoid::Matchers

  def setup
    @product = Product.new
  end

  test "should have an availability_end after availability_start" do
    assert @product.availability_end>@product.availability_start
  end

end