class SellerProfile < ApplicationRecord
  belongs_to :payment

  scope :with_successful_payments, -> { joins(:payment).where(payments: { status: "success" }) }
end