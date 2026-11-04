class Order < ApplicationRecord
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_one :payment, dependent: :destroy

  scope :with_user, -> { includes(:user) }
  scope :with_line_items, -> { includes(:line_items) }
  scope :with_payments, -> { includes(:payment) }
  scope :with_successful_payments, -> { joins(:payment).where(payments: { status: "success" }) }
  scope :without_payment, -> { left_joins(:payment).where(payments: { id: nil }) }
end
