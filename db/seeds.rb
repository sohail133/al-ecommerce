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

require 'open-uri'

electronics = Category.find_or_create_by(name: "Electronics") do |cat|
  cat.description = "Electronic devices and gadgets"
end
unless electronics.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500&h=500&fit=crop")
    electronics.image.attach(io: file, filename: "electronics.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Electronics category"
  rescue => e
    puts "✗ Failed to attach image to Electronics: #{e.message}"
  end
end

clothing = Category.find_or_create_by(name: "Clothing") do |cat|
  cat.description = "Apparel and fashion items"
end
unless clothing.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500&h=500&fit=crop")
    clothing.image.attach(io: file, filename: "clothing.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Clothing category"
  rescue => e
    puts "✗ Failed to attach image to Clothing: #{e.message}"
  end
end

home_garden = Category.find_or_create_by(name: "Home & Garden") do |cat|
  cat.description = "Home decor and gardening supplies"
end
unless home_garden.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&h=500&fit=crop")
    home_garden.image.attach(io: file, filename: "home_garden.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Home & Garden category"
  rescue => e
    puts "✗ Failed to attach image to Home & Garden: #{e.message}"
  end
end

sports = Category.find_or_create_by(name: "Sports") do |cat|
  cat.description = "Sports equipment and fitness gear"
end
unless sports.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&h=500&fit=crop")
    sports.image.attach(io: file, filename: "sports.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Sports category"
  rescue => e
    puts "✗ Failed to attach image to Sports: #{e.message}"
  end
end

beauty = Category.find_or_create_by(name: "Beauty") do |cat|
  cat.description = "Beauty and personal care products"
end
unless beauty.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&h=500&fit=crop")
    beauty.image.attach(io: file, filename: "beauty.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Beauty category"
  rescue => e
    puts "✗ Failed to attach image to Beauty: #{e.message}"
  end
end

books = Category.find_or_create_by(name: "Books") do |cat|
  cat.description = "Books and educational materials"
end
unless books.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&h=500&fit=crop")
    books.image.attach(io: file, filename: "books.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Books category"
  rescue => e
    puts "✗ Failed to attach image to Books: #{e.message}"
  end
end

sandals = Category.find_or_create_by(name: "Sandals") do |cat|
  cat.description = "Comfortable sandals for all occasions"
end
unless sandals.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=500&h=500&fit=crop")
    sandals.image.attach(io: file, filename: "sandals.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Sandals category"
  rescue => e
    puts "✗ Failed to attach image to Sandals: #{e.message}"
  end
end

baby_clothes = Category.find_or_create_by(name: "Baby Clothes") do |cat|
  cat.description = "Cute and comfortable clothing for babies"
end
unless baby_clothes.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500&h=500&fit=crop")
    baby_clothes.image.attach(io: file, filename: "baby_clothes.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Baby Clothes category"
  rescue => e
    puts "✗ Failed to attach image to Baby Clothes: #{e.message}"
  end
end

phones = Subcategory.find_or_create_by(name: "Smartphones", category: electronics) do |sub|
  sub.description = "Mobile phones and smartphones"
end
unless phones.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop")
    phones.image.attach(io: file, filename: "smartphones.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Smartphones subcategory"
  rescue => e
    puts "✗ Failed to attach image to Smartphones: #{e.message}"
  end
end

laptops = Subcategory.find_or_create_by(name: "Laptops", category: electronics) do |sub|
  sub.description = "Laptop computers"
end
unless laptops.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop")
    laptops.image.attach(io: file, filename: "laptops.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Laptops subcategory"
  rescue => e
    puts "✗ Failed to attach image to Laptops: #{e.message}"
  end
end

mens_wear = Subcategory.find_or_create_by(name: "Men's Wear", category: clothing) do |sub|
  sub.description = "Men's clothing"
end
unless mens_wear.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=500&h=500&fit=crop")
    mens_wear.image.attach(io: file, filename: "mens_wear.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Men's Wear subcategory"
  rescue => e
    puts "✗ Failed to attach image to Men's Wear: #{e.message}"
  end
end

womens_wear = Subcategory.find_or_create_by(name: "Women's Wear", category: clothing) do |sub|
  sub.description = "Women's clothing"
end
unless womens_wear.image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&h=500&fit=crop")
    womens_wear.image.attach(io: file, filename: "womens_wear.jpg", content_type: "image/jpeg")
    puts "✓ Attached image to Women's Wear subcategory"
  rescue => e
    puts "✗ Failed to attach image to Women's Wear: #{e.message}"
  end
end

product1 = Product.find_or_create_by(title: "iPhone 15 Pro") do |p|
  p.category = electronics
  p.subcategory = phones
  p.description = "Latest iPhone with advanced features"
  p.price = 999.99
  p.active = true
end
unless product1.cover_image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=500&h=500&fit=crop")
    product1.cover_image.attach(io: file, filename: "iphone_cover.jpg", content_type: "image/jpeg")
    puts "✓ Attached cover image to iPhone 15 Pro"
  rescue => e
    puts "✗ Failed to attach cover image to iPhone 15 Pro: #{e.message}"
  end
end
if product1.images.count == 0
  begin
    [
      "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=400&h=400&fit=crop"
    ].each_with_index do |url, index|
      file = URI.open(url)
      product1.images.attach(io: file, filename: "iphone_#{index + 1}.jpg", content_type: "image/jpeg")
    end
    puts "✓ Attached #{product1.images.count} gallery images to iPhone 15 Pro"
  rescue => e
    puts "✗ Failed to attach gallery images to iPhone 15 Pro: #{e.message}"
  end
end

product2 = Product.find_or_create_by(title: "MacBook Pro") do |p|
  p.category = electronics
  p.subcategory = laptops
  p.description = "Powerful laptop for professionals"
  p.price = 1999.99
  p.active = true
end
unless product2.cover_image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&h=500&fit=crop")
    product2.cover_image.attach(io: file, filename: "macbook_cover.jpg", content_type: "image/jpeg")
    puts "✓ Attached cover image to MacBook Pro"
  rescue => e
    puts "✗ Failed to attach cover image to MacBook Pro: #{e.message}"
  end
end
if product2.images.count == 0
  begin
    [
      "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop"
    ].each_with_index do |url, index|
      file = URI.open(url)
      product2.images.attach(io: file, filename: "macbook_#{index + 1}.jpg", content_type: "image/jpeg")
    end
    puts "✓ Attached #{product2.images.count} gallery images to MacBook Pro"
  rescue => e
    puts "✗ Failed to attach gallery images to MacBook Pro: #{e.message}"
  end
end

product3 = Product.find_or_create_by(title: "Cotton T-Shirt") do |p|
  p.category = clothing
  p.subcategory = mens_wear
  p.description = "Comfortable cotton t-shirt"
  p.price = 29.99
  p.active = true
end
unless product3.cover_image.attached?
  begin
    file = URI.open("https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&h=500&fit=crop")
    product3.cover_image.attach(io: file, filename: "tshirt_cover.jpg", content_type: "image/jpeg")
    puts "✓ Attached cover image to Cotton T-Shirt"
  rescue => e
    puts "✗ Failed to attach cover image to Cotton T-Shirt: #{e.message}"
  end
end
if product3.images.count == 0
  begin
    [
      "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400&h=400&fit=crop",
      "https://images.unsplash.com/photo-1562157873-818bc0726f68?w=400&h=400&fit=crop"
    ].each_with_index do |url, index|
      file = URI.open(url)
      product3.images.attach(io: file, filename: "tshirt_#{index + 1}.jpg", content_type: "image/jpeg")
    end
    puts "✓ Attached #{product3.images.count} gallery images to Cotton T-Shirt"
  rescue => e
    puts "✗ Failed to attach gallery images to Cotton T-Shirt: #{e.message}"
  end
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

store_setting = StoreSetting.instance
store_setting.update!(
  email: "info@alecommerce.com",
  phone_number: "+1 234 567 8900",
  location: "123 Main Street, City, State, ZIP Code",
  facebook_url: "https://facebook.com/alecommerce",
  instagram_url: "https://instagram.com/alecommerce",
  youtube_url: "https://youtube.com/alecommerce"
)
puts "✓ Store settings created/updated"

require 'open-uri'

hero_image1 = HeroImage.find_or_create_by(title: "Summer Collection 2024") do |hi|
  hi.subtitle = "Discover the latest trends"
  hi.description = "Shop our newest arrivals and get up to 50% off on selected items"
  hi.active = true
  hi.position = 0
end

hero_image2 = HeroImage.find_or_create_by(title: "Quality Products") do |hi|
  hi.subtitle = "Best prices guaranteed"
  hi.description = "Experience premium quality at unbeatable prices"
  hi.active = true
  hi.position = 1
end

hero_image3 = HeroImage.find_or_create_by(title: "Fast Delivery") do |hi|
  hi.subtitle = "Free shipping over $50"
  hi.description = "Get your products delivered to your doorstep in no time"
  hi.active = true
  hi.position = 2
end

[hero_image1, hero_image2, hero_image3].each_with_index do |hero_image, index|
  if hero_image.images.count == 0
    begin
      image_urls = [
        "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&h=600&fit=crop",
        "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1200&h=600&fit=crop",
        "https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1200&h=600&fit=crop"
      ]
      file = URI.open(image_urls[index])
      hero_image.images.attach(io: file, filename: "hero_#{index + 1}.jpg", content_type: "image/jpeg")
      puts "✓ Attached image to Hero Image #{index + 1}"
    rescue => e
      puts "✗ Failed to attach image to Hero Image #{index + 1}: #{e.message}"
    end
  end
end

puts "Seeds completed successfully!"
