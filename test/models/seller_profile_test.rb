require "test_helper"

class SellerProfileTest < ActiveSupport::TestCase
  test "finds seller profiles with successful payments" do
    user = User.create!(name: "Customer")
    successful_payment = user.orders.create!.create_payment!(status: "success")
    failed_payment = user.orders.create!.create_payment!(status: "failed")
    successful_profile = successful_payment.create_seller_profile!(seller_name: "Successful seller")
    failed_payment.create_seller_profile!(seller_name: "Failed seller")

    assert_equal [successful_profile], SellerProfile.with_successful_payments
  end
end
