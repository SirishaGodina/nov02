require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "finds users who purchased more than two distinct products" do
    qualifying_user = User.create!(name: "Qualifying user")
    other_user = User.create!(name: "Other user")
    qualifying_order = qualifying_user.orders.create!
    other_order = other_user.orders.create!

    products = 3.times.map { |index| Product.create!(name: "Product #{index}") }
    products.each do |product|
      qualifying_order.line_items.create!(product: product)
    end
    qualifying_order.line_items.create!(product: products.first)
    other_order.line_items.create!(product: products.first)
    other_order.line_items.create!(product: products.second)

    assert_equal [qualifying_user], User.with_more_than_two_distinct_products
  end

  test "finds users whose combined order total exceeds 100000" do
    qualifying_user = User.create!(name: "Qualifying user")
    threshold_user = User.create!(name: "Threshold user")
    qualifying_user.orders.create!(total_amount: 60_000)
    qualifying_user.orders.create!(total_amount: 40_001)
    threshold_user.orders.create!(total_amount: 100_000)

    assert_equal [qualifying_user], User.with_total_order_amount_over_100k
  end

  test "finds users with an order over 10000" do
    qualifying_user = User.create!(name: "Qualifying user")
    threshold_user = User.create!(name: "Threshold user")
    qualifying_user.orders.create!(total_amount: 10_001)
    qualifying_user.orders.create!(total_amount: 12_000)
    threshold_user.orders.create!(total_amount: 10_000)

    assert_equal [qualifying_user], User.with_orders_over_10k
  end

  test "finds users who purchased a Laptop" do
    qualifying_user = User.create!(name: "Qualifying user")
    other_user = User.create!(name: "Other user")
    order = qualifying_user.orders.create!
    another_order = qualifying_user.orders.create!
    order.line_items.create!(product: Product.create!(name: "Laptop"))
    another_order.line_items.create!(product: Product.create!(name: "Laptop"))
    other_order = other_user.orders.create!
    other_order.line_items.create!(product: Product.create!(name: "Phone"))

    assert_equal [qualifying_user], User.who_purchased_laptop
  end

  test "finds users with a purchased product quantity greater than two" do
    qualifying_user = User.create!(name: "Qualifying user")
    threshold_user = User.create!(name: "Threshold user")
    qualifying_order = qualifying_user.orders.create!
    threshold_order = threshold_user.orders.create!
    qualifying_order.line_items.create!(product: Product.create!(name: "Product"), quantity: 3)
    threshold_order.line_items.create!(product: Product.create!(name: "Another product"), quantity: 2)

    assert_equal [qualifying_user], User.with_line_items_quantity_over_two
  end

  test "calculates the order count for each user" do
    user_with_orders = User.create!(name: "Customer with orders")
    user_without_orders = User.create!(name: "Customer without orders")
    2.times { user_with_orders.orders.create! }

    users_with_counts = User.with_order_count.index_by(&:id)

    assert_equal 2, users_with_counts.fetch(user_with_orders.id).orders_count
    assert_equal 0, users_with_counts.fetch(user_without_orders.id).orders_count
  end

  test "finds users who have no orders" do
    user_without_orders = User.create!(name: "No orders")
    user_with_orders = User.create!(name: "Has orders")
    user_with_orders.orders.create!

    assert_equal [user_without_orders], User.without_orders
  end

  test "calculates the total payment amount for each user" do
    user_with_payments = User.create!(name: "Customer with payments")
    user_without_payments = User.create!(name: "Customer without payments")
    user_with_payments.orders.create!.create_payment!(amount: 60.25)
    user_with_payments.orders.create!.create_payment!(amount: 40.50)

    users_with_totals = User.with_total_payment_amount.index_by(&:id)

    assert_equal BigDecimal("100.75"), users_with_totals.fetch(user_with_payments.id).total_payment_amount
    assert_equal 0, users_with_totals.fetch(user_without_payments.id).total_payment_amount
  end

  test "loads users with their orders" do
    user = User.create!(name: "Customer")
    order = user.orders.create!

    loaded_user = User.with_orders.find(user.id)

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_equal [order], loaded_user.orders
  end

  test "selects user names and order numbers" do
    user = User.create!(name: "Customer")
    user.orders.create!(order_number: "ORD-001")

    result = User.with_name_and_order_number.first

    assert_equal user.id, result.id
    assert_equal "Customer", result.name
    assert_equal "ORD-001", result.order_number
  end

  test "loads users with their orders and payments" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    payment = order.create_payment!

    loaded_user = User.with_orders_and_payments.find(user.id)
    loaded_order = loaded_user.orders.first

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_predicate loaded_order.association(:payment), :loaded?
    assert_equal payment, loaded_order.payment
  end

  test "loads users with orders, payments, and seller profiles" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    payment = order.create_payment!
    seller_profile = payment.create_seller_profile!

    loaded_user = User.with_orders_payments_and_seller_profiles.find(user.id)
    loaded_order = loaded_user.orders.first
    loaded_payment = loaded_order.payment

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_predicate loaded_order.association(:payment), :loaded?
    assert_predicate loaded_payment.association(:seller_profile), :loaded?
    assert_equal seller_profile, loaded_payment.seller_profile
  end

  test "loads users with their orders and line items" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    line_item = order.line_items.create!(product: Product.create!(name: "Product"))

    loaded_user = User.with_orders_and_line_items.find(user.id)
    loaded_order = loaded_user.orders.first

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_predicate loaded_order.association(:line_items), :loaded?
    assert_equal [line_item], loaded_order.line_items
  end

  test "loads users with orders, line items, and products" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    product = Product.create!(name: "Product")
    line_item = order.line_items.create!(product: product)

    loaded_user = User.with_orders_line_items_and_products.find(user.id)
    loaded_order = loaded_user.orders.first
    loaded_line_item = loaded_order.line_items.first

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_predicate loaded_order.association(:line_items), :loaded?
    assert_predicate loaded_line_item.association(:product), :loaded?
    assert_equal product, loaded_line_item.product
  end

  test "loads users with all six associated tables" do
    user = User.create!(name: "Customer")
    order = user.orders.create!
    payment = order.create_payment!
    seller_profile = payment.create_seller_profile!
    product = Product.create!(name: "Product")
    line_item = order.line_items.create!(product: product)

    loaded_user = User.with_all_associations.find(user.id)
    loaded_order = loaded_user.orders.first
    loaded_payment = loaded_order.payment
    loaded_line_item = loaded_order.line_items.first

    assert_predicate loaded_user.association(:orders), :loaded?
    assert_predicate loaded_order.association(:payment), :loaded?
    assert_predicate loaded_payment.association(:seller_profile), :loaded?
    assert_predicate loaded_order.association(:line_items), :loaded?
    assert_predicate loaded_line_item.association(:product), :loaded?
    assert_equal seller_profile, loaded_payment.seller_profile
    assert_equal product, loaded_line_item.product
  end
end
