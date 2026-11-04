class User < ApplicationRecord
  has_many :orders, dependent: :destroy

  scope :without_orders, -> { where.missing(:orders) }

  scope :with_order_count, -> {
    left_joins(:orders)
      .group("users.id")
      .select("users.*, COUNT(orders.id) AS orders_count")
  }

  scope :with_total_payment_amount, -> {
    left_joins(orders: :payment)
      .group("users.id")
      .select("users.*, COALESCE(SUM(payments.amount), 0) AS total_payment_amount")
  }

  scope :with_orders, -> { includes(:orders) }
  scope :with_name_and_order_number, -> {
    joins(:orders).select("users.id, users.name, orders.order_number")
  }
  scope :with_all_associations, -> {
    includes(orders: [:payment, { line_items: :product }])
  }
  scope :with_orders_and_payments, -> { includes(orders: :payment) }
  scope :with_orders_payments_and_seller_profiles, -> { includes(orders: { payment: :seller_profile }) }
  scope :with_orders_and_line_items, -> { includes(orders: :line_items) }
  scope :with_orders_line_items_and_products, -> { includes(orders: { line_items: :product }) }

  scope :with_more_than_two_distinct_products, -> {
    joins(orders: { line_items: :product })
      .group("users.id")
      .having("COUNT(DISTINCT products.id) > 2")
  }

  scope :with_total_order_amount_over_100k, -> {
    joins(:orders)
      .group("users.id")
      .having("SUM(orders.total_amount) > ?", 100_000)
  }

  scope :with_orders_over_10k, -> {
    joins(:orders)
      .where("orders.total_amount > ?", 10_000)
      .distinct
  }

  scope :who_purchased_laptop, -> {
    joins(orders: { line_items: :product })
      .where(products: { name: "Laptop" })
      .distinct
  }

  scope :with_line_items_quantity_over_two, -> {
    joins(orders: :line_items)
      .where("line_items.quantity > ?", 2)
      .distinct
  }
end