
# Delete existing records in foreign-key order


# --------------------------------
# 1. Users
# --------------------------------

users = User.create!([
  { name: "John", email: "john@gmail.com" },
  { name: "David", email: "david@gmail.com" },
  { name: "Smith", email: "smith@gmail.com" },
  { name: "Robert", email: "robert@gmail.com" }
])

# --------------------------------
# 2. Products
# --------------------------------

products = Product.create!([
  { name: "Laptop", price: 50000, stock: 10 },
  { name: "Mobile", price: 20000, stock: 20 },
  { name: "Keyboard", price: 1500, stock: 30 },
  { name: "Mouse", price: 800, stock: 40 },
  { name: "Monitor", price: 12000, stock: 15 }
])

# --------------------------------
# 3. Orders
# --------------------------------

orders = Order.create!([
  { user_id: users[0].id, order_number: "ORD001", total_amount: 70000 },
  { user_id: users[0].id, order_number: "ORD002", total_amount: 2300 },
  { user_id: users[1].id, order_number: "ORD003", total_amount: 50000 },
  { user_id: users[2].id, order_number: "ORD004", total_amount: 20800 },
  { user_id: users[3].id, order_number: "ORD005", total_amount: 12000 }
])

# --------------------------------
# 4. Line Items
# --------------------------------

LineItem.create!([
  { order_id: orders[0].id, product_id: products[0].id, quantity: 1, price: 50000 },
  { order_id: orders[0].id, product_id: products[1].id, quantity: 1, price: 20000 },

  { order_id: orders[1].id, product_id: products[2].id, quantity: 1, price: 1500 },
  { order_id: orders[1].id, product_id: products[3].id, quantity: 1, price: 800 },

  { order_id: orders[2].id, product_id: products[0].id, quantity: 1, price: 50000 },

  { order_id: orders[3].id, product_id: products[1].id, quantity: 1, price: 20000 },
  { order_id: orders[3].id, product_id: products[3].id, quantity: 1, price: 800 },

  { order_id: orders[4].id, product_id: products[4].id, quantity: 1, price: 12000 }
])

# --------------------------------
# 5. Payments
# --------------------------------

payments = Payment.create!([
  {
    order_id: orders[0].id,
    amount: 70000,
    status: "success",
    payment_method: "Credit Card"
  },
  {
    order_id: orders[1].id,
    amount: 2300,
    status: "success",
    payment_method: "UPI"
  },
  {
    order_id: orders[2].id,
    amount: 50000,
    status: "success",
    payment_method: "Debit Card"
  },
  {
    order_id: orders[3].id,
    amount: 20800,
    status: "success",
    payment_method: "UPI"
  },
  {
    order_id: orders[4].id,
    amount: 12000,
    status: "success",
    payment_method: "Credit Card"
  }
])

# --------------------------------
# 6. Seller Profiles
# --------------------------------

SellerProfile.create!([
  {
    payment_id: payments[0].id,
    seller_name: "Raj",
    business_name: "Raj Electronics"
  },
  {
    payment_id: payments[1].id,
    seller_name: "Kumar",
    business_name: "Kumar Accessories"
  },
  {
    payment_id: payments[2].id,
    seller_name: "Ravi",
    business_name: "Ravi Computers"
  },
  {
    payment_id: payments[3].id,
    seller_name: "Arun",
    business_name: "Arun Mobiles"
  },
  {
    payment_id: payments[4].id,
    seller_name: "Vijay",
    business_name: "Vijay Technologies"
  }
])

puts "Successfully inserted all seed data!"
