class Product < ApplicationRecord
  has_many :line_items, dependent: :destroy

  scope :never_purchased, -> { where.missing(:line_items) }

  scope :priced_above_5000, -> { where("products.price > ?", 5_000) }

  scope :by_total_sales, -> {
    joins(:line_items)
      .group("products.id")
      .order(Arel.sql("SUM(line_items.quantity * line_items.price) DESC"))
  }

  scope :top_selling, -> {
    joins(:line_items)
      .group("products.id")
      .order(Arel.sql("SUM(line_items.quantity) DESC"))
      .limit(3)
  }

  scope :with_total_sales_over_50k, -> {
    joins(:line_items)
      .group("products.id")
      .having("SUM(line_items.quantity * line_items.price) > ?", 50_000)
  }
end