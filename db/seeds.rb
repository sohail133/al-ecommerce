require 'open-uri'

puts "🌱 Starting seed process (Clothing + Jewelry only)..."

# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------
puts "\n👤 Creating users..."
User.find_or_create_by(email: 'admin@example.com') do |user|
  user.full_name = 'Admin User'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :admin
  user.status = true
end
puts "  ✓ Admin user: admin@example.com / password123"

[
  'John Smith', 'Emma Johnson', 'Michael Williams', 'Sophia Brown', 'James Davis',
  'Olivia Miller', 'William Wilson', 'Ava Martinez', 'Robert Anderson', 'Isabella Taylor'
].each_with_index do |name, index|
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

# ---------------------------------------------------------------------------
# Newsletter
# ---------------------------------------------------------------------------
puts "\n📧 Creating newsletter subscribers..."
10.times do |index|
  email = "subscriber#{index + 1}@example.com"
  Subscriber.find_or_create_by(email: email) do |subscriber|
    subscriber.status = 'active'
    subscriber.subscribed_at = Time.current - rand(1..30).days
  end
  puts "  ✓ Subscriber: #{email}"
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def seed_category_attribute!(category:, name:, input_type:, required:, position:, options: [])
  attribute = category.category_attributes.find_or_initialize_by(slug: name.parameterize)
  attribute.assign_attributes(
    name: name,
    input_type: input_type,
    required: required,
    position: position
  )
  attribute.save!

  options.each_with_index do |option_value, index|
    option = attribute.category_attribute_options.find_or_initialize_by(value: option_value)
    option.position = index
    option.save!
  end

  attribute.category_attribute_options.where.not(value: options).destroy_all if options.any?
  attribute
end

def attach_remote_image(record, attachment_name, url, filename)
  attachment = record.public_send(attachment_name)
  return if attachment.attached?

  file = URI.open(url)
  if attachment.respond_to?(:attach) && attachment.is_a?(ActiveStorage::Attached::Many)
    attachment.attach(io: file, filename: filename, content_type: 'image/jpeg')
  else
    attachment.attach(io: file, filename: filename, content_type: 'image/jpeg')
  end
rescue StandardError
  puts "  ⚠ Could not attach image for #{filename}"
end

def jewelry_variants_for(product)
  title = product.title.downcase
  subcategory_name = product.subcategory&.name

  if subcategory_name == 'Rings' || (title.include?('ring') && !title.include?('earring'))
    %w[6 7 8 9].map { |size| { name: "Size #{size}", sku_suffix: "SIZE-#{size}", price_modifier: 0, attributes: { 'Ring Size' => size } } }
  elsif subcategory_name == 'Bangles' || title.include?('bangle')
    [
      { name: 'Size 2.4', sku_suffix: 'BS-24', price_modifier: 0, attributes: { 'Bangle Size' => '2.4' } },
      { name: 'Size 2.6', sku_suffix: 'BS-26', price_modifier: 0, attributes: { 'Bangle Size' => '2.6' } },
      { name: 'Size 2.8', sku_suffix: 'BS-28', price_modifier: 0, attributes: { 'Bangle Size' => '2.8' } },
      { name: 'Size 2.10', sku_suffix: 'BS-210', price_modifier: 0, attributes: { 'Bangle Size' => '2.10' } }
    ]
  elsif subcategory_name == 'Earrings' || title.include?('stud') || title.include?('earring')
    %w[Gold Silver Black White].map { |color| { name: color, sku_suffix: color.upcase, price_modifier: 0, attributes: { 'Color' => color } } }
  elsif subcategory_name == 'Locket Sets' || title.include?('locket')
    %w[Gold Silver Black].map { |color| { name: color, sku_suffix: color.upcase, price_modifier: 0, attributes: { 'Color' => color } } }
  else
    [{ name: 'Standard', sku_suffix: 'STD', price_modifier: 0, attributes: {} }]
  end
end

def clothing_variants_for(product)
  title = product.title.downcase

  if title.include?('wallet') || title.include?('cap') || title.include?('scarf')
    [
      { name: 'Black', sku_suffix: 'BLACK', price_modifier: 0, attributes: { 'Size' => 'M', 'Color' => 'Black', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'Beige', sku_suffix: 'BEIGE', price_modifier: 0, attributes: { 'Size' => 'M', 'Color' => 'Beige', 'Material' => 'Cotton', 'Fit' => 'Regular' } }
    ]
  elsif title.include?('kurta')
    [
      { name: 'M / White', sku_suffix: 'M-WHITE', price_modifier: 0, attributes: { 'Size' => 'M', 'Color' => 'White', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'L / White', sku_suffix: 'L-WHITE', price_modifier: 150, attributes: { 'Size' => 'L', 'Color' => 'White', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'XL / Navy', sku_suffix: 'XL-NAVY', price_modifier: 250, attributes: { 'Size' => 'XL', 'Color' => 'Navy', 'Material' => 'Cotton', 'Fit' => 'Relaxed' } }
    ]
  elsif title.include?('suit') || title.include?('dress')
    [
      { name: 'S / Pink', sku_suffix: 'S-PINK', price_modifier: 0, attributes: { 'Size' => 'S', 'Color' => 'Pink', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'M / Green', sku_suffix: 'M-GREEN', price_modifier: 200, attributes: { 'Size' => 'M', 'Color' => 'Green', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'L / Blue', sku_suffix: 'L-BLUE', price_modifier: 300, attributes: { 'Size' => 'L', 'Color' => 'Blue', 'Material' => 'Cotton', 'Fit' => 'Relaxed' } }
    ]
  elsif title.include?('hoodie') || title.include?('jacket')
    [
      { name: 'M / Black', sku_suffix: 'M-BLACK', price_modifier: 0, attributes: { 'Size' => 'M', 'Color' => 'Black', 'Material' => 'Denim', 'Fit' => 'Regular' } },
      { name: 'L / Navy', sku_suffix: 'L-NAVY', price_modifier: 200, attributes: { 'Size' => 'L', 'Color' => 'Navy', 'Material' => 'Denim', 'Fit' => 'Relaxed' } },
      { name: 'XL / Grey', sku_suffix: 'XL-GREY', price_modifier: 300, attributes: { 'Size' => 'XL', 'Color' => 'Grey', 'Material' => 'Polyester', 'Fit' => 'Oversized' } }
    ]
  else
    [
      { name: 'S / Blue', sku_suffix: 'S-BLUE', price_modifier: 0, attributes: { 'Size' => 'S', 'Color' => 'Blue', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'M / Black', sku_suffix: 'M-BLACK', price_modifier: 0, attributes: { 'Size' => 'M', 'Color' => 'Black', 'Material' => 'Cotton', 'Fit' => 'Regular' } },
      { name: 'L / White', sku_suffix: 'L-WHITE', price_modifier: 150, attributes: { 'Size' => 'L', 'Color' => 'White', 'Material' => 'Cotton', 'Fit' => 'Relaxed' } },
      { name: 'XL / Navy', sku_suffix: 'XL-NAVY', price_modifier: 250, attributes: { 'Size' => 'XL', 'Color' => 'Navy', 'Material' => 'Cotton', 'Fit' => 'Regular' } }
    ]
  end
end

# ---------------------------------------------------------------------------
# Categories (only Clothing + Jewelry)
# ---------------------------------------------------------------------------
puts "\n📁 Creating categories..."
categories_data = [
  {
    name: 'Clothing',
    description: 'Everyday fashion for men, women, and kids',
    img: 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500&h=500&fit=crop'
  },
  {
    name: 'Jewelry',
    description: 'Artificial jewelry — waterproof, anti-tarnish fashion pieces for everyday wear',
    img: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&h=500&fit=crop'
  }
]

categories = {}
categories_data.each do |cat_data|
  category = Category.find_or_create_by(name: cat_data[:name]) do |cat|
    cat.description = cat_data[:description]
  end
  category.update!(description: cat_data[:description])
  attach_remote_image(category, :image, cat_data[:img], "#{category.name.parameterize}.jpg")
  categories[category.name] = category
  puts "  ✓ #{category.name}"
end

# Remove leftover demo categories from older seeds
allowed_names = categories_data.map { |c| c[:name] }
Category.where.not(name: allowed_names).find_each do |category|
  puts "  ✗ Removing leftover category: #{category.name}"
  variant_ids = ProductVariant.joins(:product).where(products: { category_id: category.id }).pluck(:id)
  OrderItem.where(product_variant_id: variant_ids).delete_all
  CartItem.where(product_variant_id: variant_ids).delete_all if defined?(CartItem)
  category.destroy!
rescue StandardError => e
  puts "  ⚠ Could not remove #{category.name}: #{e.message}"
end

# ---------------------------------------------------------------------------
# Category attributes
# ---------------------------------------------------------------------------
puts "\n🏷️  Creating category attributes..."

clothing_category = categories['Clothing']
seed_category_attribute!(category: clothing_category, name: 'Size', input_type: 'select', required: true, position: 0, options: %w[XS S M L XL XXL])
seed_category_attribute!(category: clothing_category, name: 'Color', input_type: 'select', required: true, position: 1, options: %w[Black White Blue Red Green Beige Pink Navy Grey])
seed_category_attribute!(category: clothing_category, name: 'Material', input_type: 'select', required: false, position: 2, options: %w[Cotton Denim Polyester Wool Linen Silk Blend])
seed_category_attribute!(category: clothing_category, name: 'Fit', input_type: 'select', required: false, position: 3, options: ['Regular', 'Slim', 'Oversized', 'Relaxed'])
puts "  ✓ Clothing attributes (Size, Color, Material, Fit)"

jewelry_category = categories['Jewelry']
jewelry_category.category_attributes.where(name: %w[Material Karat Stone Weight]).find_each(&:destroy)
seed_category_attribute!(category: jewelry_category, name: 'Ring Size', input_type: 'select', required: false, position: 0, options: %w[6 7 8 9 10 11 12 Adjustable])
seed_category_attribute!(category: jewelry_category, name: 'Bangle Size', input_type: 'select', required: false, position: 1, options: ['2.2', '2.4', '2.6', '2.8', '2.10'])
seed_category_attribute!(category: jewelry_category, name: 'Color', input_type: 'select', required: false, position: 2, options: ['Gold', 'Silver', 'Rose Gold', 'Black', 'White'])
puts "  ✓ Jewelry attributes (Ring Size, Bangle Size, Color)"

# ---------------------------------------------------------------------------
# Subcategories
# ---------------------------------------------------------------------------
puts "\n📂 Creating subcategories..."
subcategories_data = [
  { name: "Men's Clothing", category: 'Clothing', size_required: false, img: 'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=500&h=500&fit=crop' },
  { name: "Women's Clothing", category: 'Clothing', size_required: false, img: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&h=500&fit=crop' },
  { name: "Kids' Clothing", category: 'Clothing', size_required: false, img: 'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=500&h=500&fit=crop' },
  { name: 'Accessories', category: 'Clothing', size_required: false, img: 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=500&h=500&fit=crop' },
  { name: 'Rings', category: 'Jewelry', size_required: true, img: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500&h=500&fit=crop' },
  { name: 'Necklaces', category: 'Jewelry', size_required: false, img: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500&h=500&fit=crop' },
  { name: 'Earrings', category: 'Jewelry', size_required: false, img: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500&h=500&fit=crop' },
  { name: 'Bracelets', category: 'Jewelry', size_required: false, img: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { name: 'Bangles', category: 'Jewelry', size_required: true, img: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { name: 'Locket Sets', category: 'Jewelry', size_required: false, img: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&h=500&fit=crop' },
  { name: 'Anklets', category: 'Jewelry', size_required: false, img: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' }
]

subcategories = {}
allowed_subcategory_keys = []
subcategories_data.each do |subcat_data|
  category = categories[subcat_data[:category]]
  next unless category

  subcategory = Subcategory.find_or_create_by(name: subcat_data[:name], category: category)
  subcategory.update!(size_required: subcat_data[:size_required])
  attach_remote_image(subcategory, :image, subcat_data[:img], "#{subcategory.name.parameterize}.jpg")

  key = "#{subcat_data[:category]}-#{subcat_data[:name]}"
  subcategories[key] = subcategory
  allowed_subcategory_keys << [category.id, subcat_data[:name]]
  puts "  ✓ #{subcategory.name} (#{category.name})"
end

Subcategory.includes(:category).find_each do |subcategory|
  next if allowed_subcategory_keys.include?([subcategory.category_id, subcategory.name])

  puts "  ✗ Removing leftover subcategory: #{subcategory.name}"
  subcategory.destroy!
rescue StandardError => e
  puts "  ⚠ Could not remove subcategory #{subcategory.name}: #{e.message}"
end

# ---------------------------------------------------------------------------
# Products (~20 across Clothing + Jewelry)
# ---------------------------------------------------------------------------
puts "\n📦 Creating products..."
products_data = [
  # Clothing (10)
  { title: "Men's Denim Jacket", description: 'Classic blue denim jacket with a soft vintage wash for everyday wear.', price: 4499.00, category: 'Clothing', subcategory: "Men's Clothing", cover: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&h=500&fit=crop' },
  { title: "Men's Cotton Kurta", description: 'Breathable cotton kurta for everyday and festive occasions.', price: 2499.00, category: 'Clothing', subcategory: "Men's Clothing", cover: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=500&h=500&fit=crop' },
  { title: "Men's Slim Fit Chinos", description: 'Smart casual slim-fit chinos with stretch comfort.', price: 2999.00, category: 'Clothing', subcategory: "Men's Clothing", cover: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500&h=500&fit=crop' },
  { title: "Women's Summer Dress", description: 'Elegant floral print maxi dress for daytime and evening looks.', price: 3299.00, category: 'Clothing', subcategory: "Women's Clothing", cover: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&h=500&fit=crop' },
  { title: "Women's Embroidered Lawn Suit", description: '3-piece embroidered lawn suit with matching dupatta.', price: 5499.00, category: 'Clothing', subcategory: "Women's Clothing", cover: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=500&h=500&fit=crop' },
  { title: "Women's Linen Blouse", description: 'Light linen blouse with a relaxed fit for warm days.', price: 2799.00, category: 'Clothing', subcategory: "Women's Clothing", cover: 'https://images.unsplash.com/photo-1564257631407-4deb1f623d42?w=500&h=500&fit=crop' },
  { title: "Kids' Winter Jacket", description: 'Warm and waterproof jacket made for active kids.', price: 2899.00, category: 'Clothing', subcategory: "Kids' Clothing", cover: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=500&h=500&fit=crop' },
  { title: "Kids' Printed T-Shirt Pack", description: 'Pack of soft cotton printed tees for everyday play.', price: 1799.00, category: 'Clothing', subcategory: "Kids' Clothing", cover: 'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=500&h=500&fit=crop' },
  { title: 'Unisex Hoodie', description: 'Soft fleece hoodie with front pocket and cozy fit.', price: 3199.00, category: 'Clothing', subcategory: 'Accessories', cover: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&h=500&fit=crop' },
  { title: 'Leather Wallet', description: 'Compact bi-fold wallet for everyday essentials.', price: 1999.00, category: 'Clothing', subcategory: 'Accessories', cover: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500&h=500&fit=crop' },

  # Jewelry (10)
  { title: 'Minimal Waterproof Stainless Steel Ring', description: 'Sleek minimal ring in premium stainless steel. Anti-tarnish, hypoallergenic, and waterproof.', price: 899.00, category: 'Jewelry', subcategory: 'Rings', cover: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500&h=500&fit=crop' },
  { title: 'Zircon Band Ring', description: 'Sparkling zircon stainless steel band. Available in multiple ring sizes.', price: 1099.00, category: 'Jewelry', subcategory: 'Rings', cover: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500&h=500&fit=crop' },
  { title: '18K Gold Plated Heart Pendant', description: 'Gold plated stainless steel heart pendant. Waterproof and fade-resistant.', price: 1299.00, category: 'Jewelry', subcategory: 'Necklaces', cover: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500&h=500&fit=crop' },
  { title: 'Delicate Chain Anklet', description: 'Minimal gold plated anklet in stainless steel. Adjustable and waterproof.', price: 799.00, category: 'Jewelry', subcategory: 'Anklets', cover: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { title: 'Double Sided Stud Earrings', description: 'Cute double-sided stainless steel studs. Choose your color.', price: 1199.00, category: 'Jewelry', subcategory: 'Earrings', cover: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500&h=500&fit=crop' },
  { title: 'Hoop Earrings Classic', description: 'Lightweight classic hoops in stainless steel with a polished finish.', price: 999.00, category: 'Jewelry', subcategory: 'Earrings', cover: 'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=500&h=500&fit=crop' },
  { title: 'Elara Glow Bracelet', description: '18K gold plated stainless steel bracelet. Anti-tarnish and waterproof.', price: 1350.00, category: 'Jewelry', subcategory: 'Bracelets', cover: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { title: 'Classic Clover Bracelet', description: 'Double-sided clover bracelet in stainless steel for everyday wear.', price: 999.00, category: 'Jewelry', subcategory: 'Bracelets', cover: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { title: 'Gold Plated Bangle Pair', description: 'Lightweight gold plated fashion bangles. Anti-tarnish finish.', price: 1499.00, category: 'Jewelry', subcategory: 'Bangles', cover: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500&h=500&fit=crop' },
  { title: 'Premium Clover Locket Set', description: 'Matching pendant and earrings set in stainless steel. Gift-ready.', price: 1499.00, category: 'Jewelry', subcategory: 'Locket Sets', cover: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&h=500&fit=crop' }
]

seeded_product_titles = products_data.map { |p| p[:title] }

products_data.each do |product_data|
  category = categories[product_data[:category]]
  next unless category

  subcategory = subcategories["#{product_data[:category]}-#{product_data[:subcategory]}"]
  product = Product.find_or_initialize_by(title: product_data[:title])
  product.assign_attributes(
    description: product_data[:description],
    price: product_data[:price],
    category: category,
    subcategory: subcategory,
    active: true
  )
  product.save!

  attach_remote_image(product, :cover_image, product_data[:cover], "#{product.title.parameterize}.jpg")
  puts "  ✓ #{product.title} (Rs #{product.price})"
end

# Soft-remove leftover products from older broader seeds
Product.where.not(title: seeded_product_titles).find_each do |product|
  product.update!(active: false)
  puts "  ✗ Deactivated leftover product: #{product.title}"
end

# ---------------------------------------------------------------------------
# Payment methods
# ---------------------------------------------------------------------------
puts "\n💳 Creating payment methods..."
PaymentMethod.find_or_create_by(code: 'COD') { |pm| pm.name = 'Cash on Delivery'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'CARD') { |pm| pm.name = 'Credit/Debit Card'; pm.active = true }
PaymentMethod.find_or_create_by(code: 'JAZZCASH') { |pm| pm.name = 'JazzCash'; pm.active = true }
puts "  ✓ Payment methods created"

# ---------------------------------------------------------------------------
# Variants + inventory
# ---------------------------------------------------------------------------
puts "\n📦 Creating product variants and inventory..."
variant_count = 0
inventory_count = 0

Product.active.where(title: seeded_product_titles).find_each do |product|
  variants_data =
    case product.category.name
    when 'Clothing' then clothing_variants_for(product)
    when 'Jewelry' then jewelry_variants_for(product)
    else
      [{ name: 'Standard', sku_suffix: 'STD', price_modifier: 0, attributes: {} }]
    end

  attribute_defs = product.category.category_attributes.index_by(&:name)

  variants_data.each do |variant_data|
    sku = "#{product.title.parameterize.upcase[0..10]}-#{variant_data[:sku_suffix]}"
    variant = ProductVariant.find_or_initialize_by(sku: sku)
    variant.product = product
    variant.price = [product.price + variant_data[:price_modifier], 0.01].max
    variant.active = true
    variant.name = variant_data[:name]

    if variant_data[:attributes].present?
      variant_data[:attributes].each do |attribute_name, attribute_value|
        category_attribute = attribute_defs[attribute_name]
        next unless category_attribute

        value_record = variant.attribute_values.find { |item| item.category_attribute_id == category_attribute.id } ||
                       variant.attribute_values.build(category_attribute: category_attribute)
        value_record.value = attribute_value
      end
    end

    variant.save!
    variant_count += 1

    # Variants auto-create an empty inventory row; always refill stock on seed
    inventory = Inventory.find_or_initialize_by(product_variant: variant)
    inventory.update!(
      quantity: 50,
      reserved_quantity: 0,
      threshold_level: 5
    )
    inventory_count += 1
  end
end

puts "  ✓ Created/updated #{variant_count} product variants"
puts "  ✓ Stocked #{inventory_count} inventory records (50 units each)"

# ---------------------------------------------------------------------------
# Store settings
# ---------------------------------------------------------------------------
puts "\n🏪 Updating store settings..."
StoreSetting.instance.update!(
  email: 'info@mahnira.com',
  phone_number: '+92 300 1234567',
  location: 'Lahore, Pakistan',
  facebook_url: 'https://facebook.com/mahnira',
  instagram_url: 'https://instagram.com/mahnira',
  youtube_url: 'https://youtube.com/mahnira'
)
puts "  ✓ Store settings updated"

# ---------------------------------------------------------------------------
# Hero images (fashion / jewelry focused)
# ---------------------------------------------------------------------------
puts "\n🎨 Creating hero images..."
hero_images_data = [
  {
    title: 'New Season Styles',
    subtitle: 'Clothing Collection',
    description: 'Fresh kurtas, dresses, and everyday essentials for the whole family.',
    position: 0,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=1920&h=800&fit=crop'
  },
  {
    title: 'Shine Every Day',
    subtitle: 'Artificial Jewelry',
    description: 'Waterproof, anti-tarnish rings, bracelets, and locket sets.',
    position: 1,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=1920&h=800&fit=crop'
  },
  {
    title: 'Flat Deals Live',
    subtitle: 'Up to 50% Off',
    description: 'Shop clothing and jewelry favorites at launch prices.',
    position: 2,
    active: true,
    image_url: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1920&h=800&fit=crop'
  }
]

# Keep only fashion/jewelry heroes for this catalog
HeroImage.where.not(title: hero_images_data.map { |h| h[:title] }).find_each do |hero|
  hero.update!(active: false)
end

hero_images_data.each do |data|
  hero = HeroImage.find_or_create_by(title: data[:title]) do |h|
    h.subtitle = data[:subtitle]
    h.description = data[:description]
    h.position = data[:position]
    h.active = data[:active]
  end
  hero.update!(subtitle: data[:subtitle], description: data[:description], position: data[:position], active: data[:active])

  if hero.images.blank?
    begin
      image_file = URI.open(data[:image_url])
      hero.images.attach(io: image_file, filename: "#{data[:title].parameterize}.jpg", content_type: 'image/jpeg')
      puts "  ✓ #{data[:title]}"
    rescue StandardError
      puts "  ⚠ Could not attach image for #{data[:title]}"
    end
  else
    puts "  ✓ #{data[:title]} (already exists)"
  end
end

# ---------------------------------------------------------------------------
# Contact queries (catalog-relevant)
# ---------------------------------------------------------------------------
puts "\n📮 Creating contact us queries..."
contact_us_data = [
  {
    name: 'Sara Ahmed',
    email: 'sara.ahmed@example.com',
    subject: 'Ring Size Help',
    message: 'How do I choose the right ring size for the Minimal Waterproof Stainless Steel Ring?',
    created_at: 3.days.ago
  },
  {
    name: 'Ali Khan',
    email: 'ali.khan@example.com',
    subject: 'Bangle Size',
    message: 'Do your gold plated bangles come in 2.6 and 2.8 sizes?',
    created_at: 2.days.ago,
    admin_response: 'Yes — our Gold Plated Bangle Pair is available in 2.4, 2.6, 2.8, and 2.10.',
    replied_at: 1.day.ago
  },
  {
    name: 'Fatima Noor',
    email: 'fatima.noor@example.com',
    subject: 'Lawn Suit Availability',
    message: 'Is the embroidered lawn suit available in size M?',
    created_at: 1.day.ago
  }
]

contact_us_data.each do |data|
  ContactUs.find_or_create_by(email: data[:email], subject: data[:subject]) do |c|
    c.name = data[:name]
    c.message = data[:message]
    c.created_at = data[:created_at]
    c.admin_response = data[:admin_response] if data[:admin_response]
    c.replied_at = data[:replied_at] if data[:replied_at]
  end
  puts "  ✓ #{data[:name]} - #{data[:subject]}"
end

puts "\n✅ Seeding completed successfully!"
puts "\n📊 Summary:"
puts "  - Categories: #{Category.count} (#{Category.pluck(:name).join(', ')})"
puts "  - Subcategories: #{Subcategory.count}"
puts "  - Active products: #{Product.active.count}"
puts "  - Product Variants: #{ProductVariant.count}"
puts "  - Inventory Records: #{Inventory.count}"
puts "  - Users: #{User.count}"
puts "  - Newsletter Subscribers: #{Subscriber.count}"
puts "  - Active Hero Images: #{HeroImage.active.count}"
puts "\n🔑 Login credentials:"
puts "  Admin: admin@example.com / password123"
puts "  Customers: customer1@example.com to customer10@example.com / password123"
