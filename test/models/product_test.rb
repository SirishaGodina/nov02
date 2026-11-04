require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "orders products by total sales revenue" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    lower_sales = Product.create!(name: "Lower sales")
    higher_sales = Product.create!(name: "Higher sales")
    order.line_items.create!(product: lower_sales, quantity: 2, price: 5)
    order.line_items.create!(product: higher_sales, quantity: 3, price: 10)

    assert_equal higher_sales, Product.by_total_sales.first
  end

  test "returns the three products with the most units sold" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    products = 4.times.map { |index| Product.create!(name: "Product #{index}") }
    [1, 4, 3, 2].each_with_index do |quantity, index|
      order.line_items.create!(product: products[index], quantity: quantity, price: 10)
    end

    assert_equal products.values_at(1, 2, 3), Product.top_selling
  end

  test "finds products priced above 5000" do
    expensive_product = Product.create!(name: "Expensive", price: 5_001)
    Product.create!(name: "At threshold", price: 5_000)
    Product.create!(name: "Below threshold", price: 4_999)

    assert_equal [expensive_product], Product.priced_above_5000
  end

  test "finds products with total sales above 50000" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    qualifying_product = Product.create!(name: "Qualifying product")
    threshold_product = Product.create!(name: "Threshold product")
    order.line_items.create!(product: qualifying_product, quantity: 2, price: 25_001)
    order.line_items.create!(product: threshold_product, quantity: 2, price: 25_000)

    assert_equal [qualifying_product], Product.with_total_sales_over_50k
  end

  test "finds products that have never been purchased" do
    never_purchased = Product.create!(name: "Never purchased")
    purchased = Product.create!(name: "Purchased")
    order = User.create!(name: "Customer").orders.create!
    order.line_items.create!(product: purchased)

    assert_equal [never_purchased], Product.never_purchased
  end
end
