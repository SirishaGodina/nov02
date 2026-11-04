require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "loads payments with their seller profiles" do
    order = User.create!(name: "Customer").orders.create!
    payment = order.create_payment!
    seller_profile = payment.create_seller_profile!

    loaded_payment = Payment.with_seller_profiles.find(payment.id)

    assert_predicate loaded_payment.association(:seller_profile), :loaded?
    assert_equal seller_profile, loaded_payment.seller_profile
  end
end
