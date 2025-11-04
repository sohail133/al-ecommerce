admin_user = User.find_or_create_by(email: "admin@example.com") do |user|
  user.full_name = "Admin User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
  user.status = true
end

customer_user = User.find_or_create_by(email: "customer@example.com") do |user|
  user.full_name = "Customer User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :customer
  user.status = true
end

electronics = Category.find_or_create_by(name: "Electronics") do |cat|
  cat.description = "Electronic devices and gadgets"
end

clothing = Category.find_or_create_by(name: "Clothing") do |cat|
  cat.description = "Apparel and fashion items"
end

phones = Subcategory.find_or_create_by(name: "Smartphones", category: electronics) do |sub|
  sub.description = "Mobile phones and smartphones"
end

laptops = Subcategory.find_or_create_by(name: "Laptops", category: electronics) do |sub|
  sub.description = "Laptop computers"
end

mens_wear = Subcategory.find_or_create_by(name: "Men's Wear", category: clothing) do |sub|
  sub.description = "Men's clothing"
end

womens_wear = Subcategory.find_or_create_by(name: "Women's Wear", category: clothing) do |sub|
  sub.description = "Women's clothing"
end

product1 = Product.find_or_create_by(title: "iPhone 15 Pro") do |p|
  p.category = electronics
  p.subcategory = phones
  p.description = "Latest iPhone with advanced features"
  p.price = 999.99
  p.active = true
end

product2 = Product.find_or_create_by(title: "MacBook Pro") do |p|
  p.category = electronics
  p.subcategory = laptops
  p.description = "Powerful laptop for professionals"
  p.price = 1999.99
  p.active = true
end

product3 = Product.find_or_create_by(title: "Cotton T-Shirt") do |p|
  p.category = clothing
  p.subcategory = mens_wear
  p.description = "Comfortable cotton t-shirt"
  p.price = 29.99
  p.active = true
end

variant1 = ProductVariant.find_or_create_by(sku: "IPHONE-15-128GB") do |v|
  v.product = product1
  v.name = "128GB - Space Gray"
  v.price = 999.99
  v.active = true
end

variant2 = ProductVariant.find_or_create_by(sku: "MBP-14-M1") do |v|
  v.product = product2
  v.name = "14 inch - M1 Chip"
  v.price = 1999.99
  v.active = true
end

variant3 = ProductVariant.find_or_create_by(sku: "TSHIRT-M-BLUE") do |v|
  v.product = product3
  v.name = "Medium - Blue"
  v.price = 29.99
  v.active = true
end

Inventory.find_or_create_by(product_variant: variant1) do |inv|
  inv.quantity = 50
  inv.reserved_quantity = 0
  inv.threshold_level = 10
end

Inventory.find_or_create_by(product_variant: variant2) do |inv|
  inv.quantity = 30
  inv.reserved_quantity = 0
  inv.threshold_level = 5
end

Inventory.find_or_create_by(product_variant: variant3) do |inv|
  inv.quantity = 100
  inv.reserved_quantity = 0
  inv.threshold_level = 20
end

cod = PaymentMethod.find_or_create_by(code: "COD") do |pm|
  pm.name = "Cash on Delivery"
  pm.active = true
end

jazzcash = PaymentMethod.find_or_create_by(code: "JAZZCASH") do |pm|
  pm.name = "JazzCash"
  pm.active = true
end

card = PaymentMethod.find_or_create_by(code: "CARD") do |pm|
  pm.name = "Credit/Debit Card"
  pm.active = true
end

address = Address.find_or_create_by(user: customer_user, is_default: true) do |addr|
  addr.full_name = "Customer User"
  addr.phone_number = "+1234567890"
  addr.address_line_1 = "123 Main Street"
  addr.address_line_2 = "Apt 4B"
  addr.city = "Lahore"
  addr.province = "Punjab"
  addr.postal_code = "54000"
end

order = Order.find_or_create_by(user: customer_user, status: :pending) do |o|
  o.address = address
  o.payment_method = cod
  o.total_amount = 29.99
end

OrderItem.find_or_create_by(order: order, product_variant: variant3) do |oi|
  oi.quantity = 1
  oi.price = 29.99
  oi.subtotal = 29.99
end

puts "Seeds completed successfully!"
