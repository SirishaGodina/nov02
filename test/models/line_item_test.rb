require "test_helper"

class LineItemTest < ActiveSupport::TestCase
  test "loads line items with their products" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    product = Product.create!(name: "Product")
    line_item = order.line_items.create!(product: product)

    loaded_line_item = LineItem.with_product.find(line_item.id)

    assert_predicate loaded_line_item.association(:product), :loaded?
    assert_equal product, loaded_line_item.product
  end
end
