require 'open-uri'

puts "🌱 Starting seed process..."

# Create admin user if doesn't exist
puts "\n👤 Creating users..."
admin = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.full_name = 'Admin User'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :admin
  user.status = true
end
puts "  ✓ Admin user: admin@example.com / password123"

# Create 10 customer users
customer_names = [
  'John Smith',
  'Emma Johnson',
  'Michael Williams',
  'Sophia Brown',
  'James Davis',
  'Olivia Miller',
  'William Wilson',
  'Ava Martinez',
  'Robert Anderson',
  'Isabella Taylor'
]

customer_names.each_with_index do |name, index|
  email = "customer#{index + 1}@example.com"
  User.find_or_create_by(email: email) do |user|
    user.full_name = name
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.role = :customer
    user.status = true
  end
  puts "  ✓ Customer: #{name} (#{email})"
end

# Create newsletter subscribers
puts "\n📧 Creating newsletter subscribers..."
subscriber_emails = [
  'subscriber1@example.com',
  'subscriber2@example.com',
  'subscriber3@example.com',
  'subscriber4@example.com',
  'subscriber5@example.com',
  'subscriber6@example.com',
  'subscriber7@example.com',
  'subscriber8@example.com',
  'subscriber9@example.com',
  'subscriber10@example.com'
]

subscriber_emails.each do |email|
  Subscriber.find_or_create_by(email: email) do |subscriber|
    subscriber.status = 'active'
    subscriber.subscribed_at = Time.current - rand(1..30).days
  end
  puts "  ✓ Subscriber: #{email}"
end

# Create Categories
puts "\n📁 Creating categories..."
categories_data = [
  { name: 'Electronics', description: 'Electronic devices and gadgets', img: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=500&h=500&fit=crop' },
  { name: 'Clothing', description: 'Fashion and apparel for all', img: 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500&h=500&fit=crop' },
  { name: 'Home & Kitchen', description: 'Everything for your home', img: 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=500&h=500&fit=crop' },
  { name: 'Books', description: 'Books and reading materials', img: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&h=500&fit=crop' },
  { name: 'Sports & Outdoors', description: 'Sports equipment and outdoor gear', img: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&h=500&fit=crop' },
  { name: 'Toys & Games', description: 'Toys and games for all ages', img: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=500&h=500&fit=crop' },
  { name: 'Beauty & Personal Care', description: 'Beauty products and personal care items', img: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&h=500&fit=crop' },
  { name: 'Automotive', description: 'Car accessories and parts', img: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=500&h=500&fit=crop' },
  { name: 'Grocery', description: 'Food and beverages', img: 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=500&h=500&fit=crop' },
  { name: 'Health & Wellness', description: 'Health and wellness products', img: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=500&h=500&fit=crop' },
  { name: 'Office Supplies', description: 'Office equipment and supplies', img: 'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=500&h=500&fit=crop' },
  { name: 'Pet Supplies', description: 'Products for your pets', img: 'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=500&h=500&fit=crop' },
  { name: 'Jewelry', description: 'Jewelry and accessories', img: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&h=500&fit=crop' },
  { name: 'Baby Products', description: 'Products for babies and toddlers', img: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=500&h=500&fit=crop' },
  { name: 'Musical Instruments', description: 'Musical instruments and accessories', img: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&h=500&fit=crop' },
  { name: 'Garden & Outdoor', description: 'Garden tools and outdoor furniture', img: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=500&h=500&fit=crop' },
  { name: 'Tools & Home Improvement', description: 'Tools for home improvement', img: 'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=500&h=500&fit=crop' },
  { name: 'Arts & Crafts', description: 'Art supplies and craft materials', img: 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=500&h=500&fit=crop' },
  { name: 'Shoes', description: 'Footwear for everyone', img: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500&h=500&fit=crop' },
  { name: 'Bags & Luggage', description: 'Bags, backpacks, and luggage', img: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&h=500&fit=crop' }
]

categories = {}
categories_data.each do |cat_data|
  category = Category.find_or_create_by(name: cat_data[:name]) do |cat|
    cat.description = cat_data[:description]
  end
  
  if category.persisted? && !category.image.attached?
    begin
      file = URI.open(cat_data[:img])
      category.image.attach(io: file, filename: "#{category.name.parameterize}.jpg", content_type: 'image/jpeg')
    rescue => e
      puts "  ⚠ Could not attach image for #{category.name}"
    end
  end
  
  categories[category.name] = category
  puts "  ✓ #{category.name}"
end

# Create Subcategories
puts "\n📂 Creating subcategories..."
subcategories_data = [
  { name: 'Smartphones', category: 'Electronics', img: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop' },
  { name: 'Laptops', category: 'Electronics', img: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop' },
  { name: 'Tablets', category: 'Electronics', img: 'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=500&h=500&fit=crop' },
  { name: 'Headphones', category: 'Electronics', img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop' },
  { name: 'Cameras', category: 'Electronics', img: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=500&h=500&fit=crop' },
  { name: 'Men\'s Clothing', category: 'Clothing', img: 'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=500&h=500&fit=crop' },
  { name: 'Women\'s Clothing', category: 'Clothing', img: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&h=500&fit=crop' },
  { name: 'Kids\' Clothing', category: 'Clothing', img: 'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=500&h=500&fit=crop' },
  { name: 'Accessories', category: 'Clothing', img: 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=500&h=500&fit=crop' },
  { name: 'Furniture', category: 'Home & Kitchen', img: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&h=500&fit=crop' },
  { name: 'Kitchen Appliances', category: 'Home & Kitchen', img: 'https://images.unsplash.com/photo-1585659722983-2a0c0de4e7ec?w=500&h=500&fit=crop' },
  { name: 'Bedding', category: 'Home & Kitchen', img: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500&h=500&fit=crop' },
  { name: 'Home Decor', category: 'Home & Kitchen', img: 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=500&h=500&fit=crop' },
  { name: 'Fiction', category: 'Books', img: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop' },
  { name: 'Non-Fiction', category: 'Books', img: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500&h=500&fit=crop' },
  { name: 'Children\'s Books', category: 'Books', img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop' },
  { name: 'Fitness Equipment', category: 'Sports & Outdoors', img: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&h=500&fit=crop' },
  { name: 'Camping Gear', category: 'Sports & Outdoors', img: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500&h=500&fit=crop' },
  { name: 'Team Sports', category: 'Sports & Outdoors', img: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=500&h=500&fit=crop' },
  { name: 'Action Figures', category: 'Toys & Games', img: 'https://images.unsplash.com/photo-1515378960530-7c0da6231fb1?w=500&h=500&fit=crop' },
  { name: 'Board Games', category: 'Toys & Games', img: 'https://images.unsplash.com/photo-1632501641765-e568d28b0015?w=500&h=500&fit=crop' },
  { name: 'Skincare', category: 'Beauty & Personal Care', img: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&h=500&fit=crop' },
  { name: 'Makeup', category: 'Beauty & Personal Care', img: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500&h=500&fit=crop' }
]

subcategories = {}
subcategories_data.each do |subcat_data|
  category = categories[subcat_data[:category]]
  next unless category
  
  subcategory = Subcategory.find_or_create_by(name: subcat_data[:name], category: category)
  
  if subcategory.persisted? && !subcategory.image.attached?
    begin
      file = URI.open(subcat_data[:img])
      subcategory.image.attach(io: file, filename: "#{subcategory.name.parameterize}.jpg", content_type: 'image/jpeg')
    rescue => e
      puts "  ⚠ Could not attach image for #{subcategory.name}"
    end
  end
  
  subcategories["#{subcat_data[:category]}-#{subcat_data[:name]}"] = subcategory
  puts "  ✓ #{subcategory.name} (#{category.name})"
end

# Create Products
puts "\n📦 Creating products..."
products_data = [
  { title: 'iPhone 15 Pro Max', description: 'Latest Apple smartphone with A17 Pro chip and titanium design', price: 1199.99, category: 'Electronics', subcategory: 'Smartphones', cover: 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=500&h=500&fit=crop' },
  { title: 'Samsung Galaxy S24 Ultra', description: 'Flagship Android phone with S Pen and 200MP camera', price: 1099.99, category: 'Electronics', subcategory: 'Smartphones', cover: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop' },
  { title: 'Google Pixel 8 Pro', description: 'Pure Android experience with amazing AI features', price: 899.99, category: 'Electronics', subcategory: 'Smartphones', cover: 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500&h=500&fit=crop' },
  { title: 'MacBook Pro 16"', description: 'Powerful laptop with M3 Max chip for professionals', price: 2999.99, category: 'Electronics', subcategory: 'Laptops', cover: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&h=500&fit=crop' },
  { title: 'Dell XPS 15', description: 'Premium Windows laptop with stunning OLED display', price: 1899.99, category: 'Electronics', subcategory: 'Laptops', cover: 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=500&h=500&fit=crop' },
  { title: 'Lenovo ThinkPad X1', description: 'Business laptop with legendary keyboard', price: 1699.99, category: 'Electronics', subcategory: 'Laptops', cover: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop' },
  { title: 'iPad Pro 12.9"', description: 'Powerful tablet with M2 chip and ProMotion display', price: 1099.99, category: 'Electronics', subcategory: 'Tablets', cover: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500&h=500&fit=crop' },
  { title: 'Sony WH-1000XM5', description: 'Industry-leading noise canceling headphones', price: 399.99, category: 'Electronics', subcategory: 'Headphones', cover: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop' },
  { title: 'AirPods Pro 2', description: 'Wireless earbuds with adaptive audio', price: 249.99, category: 'Electronics', subcategory: 'Headphones', cover: 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=500&h=500&fit=crop' },
  { title: 'Canon EOS R6', description: 'Full-frame mirrorless camera for professionals', price: 2499.99, category: 'Electronics', subcategory: 'Cameras', cover: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=500&h=500&fit=crop' },
  { title: 'Men\'s Denim Jacket', description: 'Classic blue denim jacket with vintage wash', price: 89.99, category: 'Clothing', subcategory: 'Men\'s Clothing', cover: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&h=500&fit=crop' },
  { title: 'Women\'s Summer Dress', description: 'Elegant floral print maxi dress', price: 59.99, category: 'Clothing', subcategory: 'Women\'s Clothing', cover: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&h=500&fit=crop' },
  { title: 'Kids\' Winter Jacket', description: 'Warm and waterproof jacket for children', price: 69.99, category: 'Clothing', subcategory: 'Kids\' Clothing', cover: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=500&h=500&fit=crop' },
  { title: 'Leather Wallet', description: 'Genuine leather bi-fold wallet', price: 49.99, category: 'Clothing', subcategory: 'Accessories', cover: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500&h=500&fit=crop' },
  { title: 'Modern Coffee Table', description: 'Sleek wooden coffee table with storage', price: 299.99, category: 'Home & Kitchen', subcategory: 'Furniture', cover: 'https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=500&h=500&fit=crop' },
  { title: 'Instant Pot Duo 7-in-1', description: 'Electric pressure cooker and slow cooker', price: 89.99, category: 'Home & Kitchen', subcategory: 'Kitchen Appliances', cover: 'https://images.unsplash.com/photo-1585659722983-2a0c0de4e7ec?w=500&h=500&fit=crop' },
  { title: 'Egyptian Cotton Sheets', description: 'Luxury 1000-thread count bed sheets', price: 149.99, category: 'Home & Kitchen', subcategory: 'Bedding', cover: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=500&h=500&fit=crop' },
  { title: 'Wall Art Canvas Set', description: 'Modern abstract art (3-piece set)', price: 89.99, category: 'Home & Kitchen', subcategory: 'Home Decor', cover: 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=500&h=500&fit=crop' },
  { title: 'The Midnight Library', description: 'Bestselling fiction by Matt Haig', price: 16.99, category: 'Books', subcategory: 'Fiction', cover: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop' },
  { title: 'Atomic Habits', description: 'Transform your life with tiny changes', price: 18.99, category: 'Books', subcategory: 'Non-Fiction', cover: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&h=500&fit=crop' },
  { title: 'Harry Potter Box Set', description: 'Complete 7-book collection', price: 99.99, category: 'Books', subcategory: 'Children\'s Books', cover: 'https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=500&h=500&fit=crop' },
  { title: 'Yoga Mat Premium', description: 'Extra thick 6mm yoga mat with strap', price: 39.99, category: 'Sports & Outdoors', subcategory: 'Fitness Equipment', cover: 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=500&h=500&fit=crop' },
  { title: 'Camping Tent 4-Person', description: 'Waterproof tent with easy setup', price: 149.99, category: 'Sports & Outdoors', subcategory: 'Camping Gear', cover: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500&h=500&fit=crop' },
  { title: 'Basketball Official Size', description: 'Indoor/outdoor composite leather ball', price: 29.99, category: 'Sports & Outdoors', subcategory: 'Team Sports', cover: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500&h=500&fit=crop' },
  { title: 'LEGO Star Wars Set', description: 'Build the Millennium Falcon (1351 pieces)', price: 159.99, category: 'Toys & Games', subcategory: 'Action Figures', cover: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=500&h=500&fit=crop' },
  { title: 'Monopoly Classic Board Game', description: 'The classic property trading game', price: 29.99, category: 'Toys & Games', subcategory: 'Board Games', cover: 'https://images.unsplash.com/photo-1632501641765-e568d28b0015?w=500&h=500&fit=crop' },
  { title: 'Vitamin C Serum', description: 'Anti-aging face serum with hyaluronic acid', price: 34.99, category: 'Beauty & Personal Care', subcategory: 'Skincare', cover: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500&h=500&fit=crop' },
  { title: 'Makeup Brush Set Professional', description: '12-piece professional brush set', price: 49.99, category: 'Beauty & Personal Care', subcategory: 'Makeup', cover: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=500&h=500&fit=crop' },
  { title: 'Wireless Gaming Mouse', description: 'RGB gaming mouse with 16,000 DPI', price: 69.99, category: 'Electronics', subcategory: nil, cover: 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=500&h=500&fit=crop' },
  { title: 'Standing Desk Adjustable', description: 'Electric standing desk converter', price: 399.99, category: 'Office Supplies', subcategory: nil, cover: 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=500&h=500&fit=crop' }
]

products_data.each do |product_data|
  category = categories[product_data[:category]]
  next unless category
  
  subcategory_key = "#{product_data[:category]}-#{product_data[:subcategory]}"
  subcategory = product_data[:subcategory] ? subcategories[subcategory_key] : nil
  
  product = Product.find_or_create_by(title: product_data[:title]) do |p|
    p.description = product_data[:description]
    p.price = product_data[:price]
    p.category = category
    p.subcategory = subcategory
    p.active = true
  end
  
  if product.persisted? && !product.cover_image.attached?
    begin
      file = URI.open(product_data[:cover])
      product.cover_image.attach(io: file, filename: "#{product.title.parameterize}.jpg", content_type: 'image/jpeg')
    rescue => e
      puts "  ⚠ Could not attach cover image for #{product.title}"
    end
  end
  
  puts "  ✓ #{product.title} ($#{product.price})"
end

# Create payment methods
puts "\n💳 Creating payment methods..."
PaymentMethod.find_or_create_by(code: 'COD') { |pm| pm.name = 'Cash on Delivery'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'CARD') { |pm| pm.name = 'Credit/Debit Card'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'JAZZCASH') { |pm| pm.name = 'JazzCash'; pm.active = true }
puts "  ✓ Payment methods created"

# Create Product Variants with Inventory
puts "\n📦 Creating product variants and inventory..."
variant_count = 0
inventory_count = 0

Product.find_each do |product|
  # Define variants based on product category
  variants_data = case product.category.name
  when 'Electronics'
    if product.title.include?('Phone') || product.title.include?('iPhone') || product.title.include?('Galaxy') || product.title.include?('Pixel')
      [
        { name: '128GB - Black', sku_suffix: '128GB-BLACK', price_modifier: 0 },
        { name: '256GB - Silver', sku_suffix: '256GB-SILVER', price_modifier: 100 },
        { name: '512GB - Gold', sku_suffix: '512GB-GOLD', price_modifier: 200 }
      ]
    elsif product.title.include?('Laptop') || product.title.include?('MacBook') || product.title.include?('Dell') || product.title.include?('Lenovo')
      [
        { name: '8GB RAM / 256GB SSD', sku_suffix: '8GB-256GB', price_modifier: 0 },
        { name: '16GB RAM / 512GB SSD', sku_suffix: '16GB-512GB', price_modifier: 300 },
        { name: '32GB RAM / 1TB SSD', sku_suffix: '32GB-1TB', price_modifier: 600 }
      ]
    elsif product.title.include?('Headphones') || product.title.include?('AirPods')
      [
        { name: 'Black', sku_suffix: 'BLACK', price_modifier: 0 },
        { name: 'White', sku_suffix: 'WHITE', price_modifier: 0 },
        { name: 'Silver', sku_suffix: 'SILVER', price_modifier: 0 }
      ]
    else
      [
        { name: 'Standard - Black', sku_suffix: 'STD-BLACK', price_modifier: 0 },
        { name: 'Standard - White', sku_suffix: 'STD-WHITE', price_modifier: 0 },
        { name: 'Premium - Silver', sku_suffix: 'PREM-SILVER', price_modifier: 50 }
      ]
    end
  when 'Clothing'
    [
      { name: 'Small - Blue', sku_suffix: 'S-BLUE', price_modifier: 0 },
      { name: 'Medium - Black', sku_suffix: 'M-BLACK', price_modifier: 0 },
      { name: 'Large - Red', sku_suffix: 'L-RED', price_modifier: 5 }
    ]
  when 'Shoes'
    [
      { name: 'Size 8', sku_suffix: 'SIZE-8', price_modifier: 0 },
      { name: 'Size 9', sku_suffix: 'SIZE-9', price_modifier: 0 },
      { name: 'Size 10', sku_suffix: 'SIZE-10', price_modifier: 0 }
    ]
  when 'Books'
    [
      { name: 'Paperback', sku_suffix: 'PAPERBACK', price_modifier: 0 },
      { name: 'Hardcover', sku_suffix: 'HARDCOVER', price_modifier: 8 },
      { name: 'Kindle Edition', sku_suffix: 'KINDLE', price_modifier: -5 }
    ]
  when 'Toys & Games'
    [
      { name: 'Standard Edition', sku_suffix: 'STD', price_modifier: 0 },
      { name: 'Deluxe Edition', sku_suffix: 'DELUXE', price_modifier: 20 },
      { name: 'Collector\'s Edition', sku_suffix: 'COLLECTOR', price_modifier: 40 }
    ]
  else
    [
      { name: 'Standard', sku_suffix: 'STD', price_modifier: 0 },
      { name: 'Premium', sku_suffix: 'PREM', price_modifier: 20 },
      { name: 'Deluxe', sku_suffix: 'DLX', price_modifier: 40 }
    ]
  end

  variants_data.each do |variant_data|
    sku = "#{product.title.parameterize.upcase[0..10]}-#{variant_data[:sku_suffix]}"
    
    variant = ProductVariant.find_or_create_by(sku: sku) do |v|
      v.product = product
      v.name = variant_data[:name]
      v.price = product.price + variant_data[:price_modifier]
      v.active = true
    end
    
    if variant.persisted?
      variant_count += 1
      
      # Create inventory for this variant
      inventory = Inventory.find_or_create_by(product_variant: variant) do |inv|
        inv.quantity = 30
        inv.reserved_quantity = 0
        inv.threshold_level = 5
      end
      
      if inventory.persisted?
        inventory_count += 1
      end
    end
  end
end

puts "  ✓ Created #{variant_count} product variants"
puts "  ✓ Created #{inventory_count} inventory records (30 units each)"

# Create payment methods
puts "\n💳 Creating payment methods..."
PaymentMethod.find_or_create_by(code: 'COD') { |pm| pm.name = 'Cash on Delivery'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'CARD') { |pm| pm.name = 'Credit/Debit Card'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'JAZZCASH') { |pm| pm.name = 'JazzCash'; pm.active = true }
puts "  ✓ Payment methods created"

# Update store settings
puts "\n🏪 Updating store settings..."
store_setting = StoreSetting.instance
store_setting.update!(
  email: 'info@alecommerce.com',
  phone_number: '+1 234 567 8900',
  location: '123 Main Street, City, State, ZIP Code',
  facebook_url: 'https://facebook.com/alecommerce',
  instagram_url: 'https://instagram.com/alecommerce',
  youtube_url: 'https://youtube.com/alecommerce'
)
puts "  ✓ Store settings updated"

# Create Hero Images
puts "\n🎨 Creating hero images..."
hero_images_data = [
  {
    title: 'Summer Sale 2024',
    subtitle: 'Up to 50% Off',
    description: 'Shop the best deals of the season on electronics, fashion, and more!',
    position: 0,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1920&h=800&fit=crop'
  },
  {
    title: 'New Arrivals',
    subtitle: 'Latest Fashion Trends',
    description: 'Discover the newest styles and hottest trends for this season',
    position: 1,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=1920&h=800&fit=crop'
  },
  {
    title: 'Electronics Sale',
    subtitle: 'Tech at Amazing Prices',
    description: 'Upgrade your tech with exclusive deals on smartphones, laptops, and accessories',
    position: 2,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=1920&h=800&fit=crop'
  },
  {
    title: 'Home Essentials',
    subtitle: 'Transform Your Space',
    description: 'Quality furniture and decor to make your house a home',
    position: 3,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1920&h=800&fit=crop'
  },
  {
    title: 'Fitness & Sports',
    subtitle: 'Gear Up for Success',
    description: 'Premium sports equipment and fitness gear for your active lifestyle',
    position: 4,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=1920&h=800&fit=crop'
  }
]

hero_images_data.each do |data|
  hero = HeroImage.find_or_create_by(title: data[:title]) do |h|
    h.subtitle = data[:subtitle]
    h.description = data[:description]
    h.position = data[:position]
    h.active = data[:active]
  end

  if hero.persisted? && hero.images.blank?
    begin
      image_file = URI.open(data[:image_url])
      hero.images.attach(io: image_file, filename: "#{data[:title].parameterize}.jpg")
      puts "  ✓ #{data[:title]}"
    rescue => e
      puts "  ⚠ Could not attach image for #{data[:title]}"
    end
  else
    puts "  ✓ #{data[:title]} (already exists)"
  end
end

# Create Contact Us Queries
puts "\n📮 Creating contact us queries..."
contact_us_data = [
  {
    name: 'Sarah Johnson',
    email: 'sarah.j@example.com',
    subject: 'Product Inquiry',
    message: 'Hi, I would like to know more about the warranty on the MacBook Pro 16". Does it come with international warranty coverage?',
    created_at: 5.days.ago
  },
  {
    name: 'Michael Chen',
    email: 'michael.chen@example.com',
    subject: 'Order Delay',
    message: 'My order #12345 was supposed to arrive 2 days ago but I haven\'t received it yet. Can you please check the status?',
    created_at: 3.days.ago
  },
  {
    name: 'Emily Rodriguez',
    email: 'emily.r@example.com',
    subject: 'Return Request',
    message: 'I received the wrong size for the shoes I ordered. How can I exchange them for the correct size?',
    created_at: 7.days.ago,
    admin_response: 'Thank you for contacting us. We apologize for the inconvenience. Please ship the item back to us and we will send you the correct size immediately.',
    replied_at: 6.days.ago
  },
  {
    name: 'David Thompson',
    email: 'david.t@example.com',
    subject: 'Payment Issue',
    message: 'I tried to place an order but my payment was declined even though I have sufficient funds. Can you help?',
    created_at: 1.day.ago
  },
  {
    name: 'Lisa Anderson',
    email: 'lisa.anderson@example.com',
    subject: 'Bulk Order Inquiry',
    message: 'I am interested in ordering 50 units of the yoga mats for my fitness studio. Do you offer bulk discounts?',
    created_at: 4.days.ago,
    admin_response: 'Yes, we do offer bulk discounts! For orders over 50 units, you can get 15% off. I will send you a detailed quote via email.',
    replied_at: 3.days.ago
  },
  {
    name: 'Robert Martinez',
    email: 'robert.m@example.com',
    subject: 'Product Availability',
    message: 'When will the iPhone 15 Pro Max in Gold color be back in stock? I\'ve been waiting for weeks.',
    created_at: 2.days.ago
  },
  {
    name: 'Jennifer Lee',
    email: 'jennifer.lee@example.com',
    subject: 'Shipping Information',
    message: 'Do you ship internationally? I\'m located in Canada and interested in several products.',
    created_at: 8.days.ago,
    admin_response: 'Yes, we ship to Canada! Shipping usually takes 7-10 business days. Shipping costs are calculated at checkout based on your location.',
    replied_at: 7.days.ago
  },
  {
    name: 'Thomas Wilson',
    email: 'thomas.w@example.com',
    subject: 'Product Review',
    message: 'I recently purchased the Sony headphones and I absolutely love them! Just wanted to share my positive experience.',
    created_at: 10.days.ago,
    admin_response: 'Thank you so much for your kind words! We\'re thrilled to hear you\'re enjoying your purchase. Your feedback means a lot to us!',
    replied_at: 9.days.ago
  },
  {
    name: 'Amanda Brown',
    email: 'amanda.b@example.com',
    subject: 'Gift Wrapping Service',
    message: 'Do you offer gift wrapping services? I want to send a product as a gift to my friend.',
    created_at: 6.days.ago
  },
  {
    name: 'Christopher Davis',
    email: 'chris.davis@example.com',
    subject: 'Account Login Issue',
    message: 'I\'m unable to login to my account. I keep getting an error message. Can you please help me reset my password?',
    created_at: 1.day.ago
  }
]

contact_us_data.each do |data|
  contact = ContactUs.find_or_create_by(email: data[:email], subject: data[:subject]) do |c|
    c.name = data[:name]
    c.message = data[:message]
    c.created_at = data[:created_at]
    c.admin_response = data[:admin_response] if data[:admin_response]
    c.replied_at = data[:replied_at] if data[:replied_at]
  end

  if contact.persisted?
    puts "  ✓ #{data[:name]} - #{data[:subject]}"
  end
end

puts "\n✅ Seeding completed successfully!"
puts "\n📊 Summary:"
puts "  - Categories: #{Category.count}"
puts "  - Subcategories: #{Subcategory.count}"
puts "  - Products: #{Product.count}"
puts "  - Product Variants: #{ProductVariant.count}"
puts "  - Inventory Records: #{Inventory.count}"
puts "  - Users: #{User.count}"
puts "  - Customers: #{User.where(role: 'customer').count}"
puts "  - Newsletter Subscribers: #{Subscriber.count}"
puts "  - Hero Images: #{HeroImage.count}"
puts "  - Contact Queries: #{ContactUs.count} (#{ContactUs.replied.count} replied, #{ContactUs.unreplied.count} pending)"
puts "\n🔑 Login credentials:"
puts "  Admin: admin@example.com / password123"
puts "  Customers: customer1@example.com to customer10@example.com / password123"
