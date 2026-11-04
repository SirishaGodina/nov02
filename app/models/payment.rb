class Payment < ApplicationRecord
  belongs_to :order

  has_one :seller_profile, dependent: :destroy

  scope :with_seller_profiles, -> { includes(:seller_profile) }
end