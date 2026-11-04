require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "finds orders without a payment" do
    user = User.create!(name: "Customer")
    unpaid_order = user.orders.create!
    paid_order = user.orders.create!
    paid_order.create_payment!

    assert_equal [unpaid_order], Order.without_payment
  end

  test "loads orders with their users" do
    user = User.create!(name: "Customer")
    order = user.orders.create!

    loaded_order = Order.with_user.find(order.id)

    assert_predicate loaded_order.association(:user), :loaded?
    assert_equal user, loaded_order.user
  end

  test "loads orders with their line items" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    product = Product.create!(name: "Product")
    line_item = order.line_items.create!(product: product)

    loaded_order = Order.with_line_items.find(order.id)

    assert_predicate loaded_order.association(:line_items), :loaded?
    assert_equal [line_item], loaded_order.line_items
  end

  test "loads orders with their payments" do
    user = User.create!(name: "Customer")
    order_with_payment = user.orders.create!
    order_without_payment = user.orders.create!
    payment = order_with_payment.create_payment!

    loaded_orders = Order.with_payments.index_by(&:id)
    loaded_paid_order = loaded_orders.fetch(order_with_payment.id)
    loaded_unpaid_order = loaded_orders.fetch(order_without_payment.id)

    assert_equal [order_with_payment.id, order_without_payment.id].sort, loaded_orders.keys.sort
    assert_predicate loaded_paid_order.association(:payment), :loaded?
    assert_predicate loaded_unpaid_order.association(:payment), :loaded?
    assert_equal payment, loaded_paid_order.payment
    assert_nil loaded_unpaid_order.payment
  end

  test "finds orders with successful payments" do
    user = User.create!(name: "Customer")
    successful_order = user.orders.create!
    failed_order = user.orders.create!
    unpaid_order = user.orders.create!
    successful_order.create_payment!(status: "success")
    failed_order.create_payment!(status: "failed")

    assert_equal [successful_order], Order.with_successful_payments
  end
end
