class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  scope :with_product, -> { includes(:product) }
end