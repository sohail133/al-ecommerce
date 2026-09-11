# frozen_string_literal: true

# Import products scraped from Markaz into Mahnira.
#
# Usage:
#   bundle exec rails runner script/import_markaz_products.rb
#   bundle exec rails runner script/import_markaz_products.rb db/data/markaz_products.json
#
# Optional:
#   SKIP_SUBCATEGORY_IMAGES=1 bundle exec rails runner script/import_markaz_products.rb

require "json"
require "open-uri"
require "stringio"

json_path = ARGV[0].presence || Rails.root.join("db/data/markaz_products.json").to_s
payload = JSON.parse(File.read(json_path))
products_data = payload.fetch("products")

SUBCATEGORY_IMAGES = {
  /2\s*piece|3\s*piece|suit|stitched|lawn|kurti|skirt/i =>
    "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&h=800&fit=crop",
  /women/i =>
    "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&h=800&fit=crop",
  /men/i =>
    "https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=800&h=800&fit=crop",
  /kid|child|baby/i =>
    "https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=800&h=800&fit=crop",
  /bag|backpack|purse|handbag/i =>
    "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&h=800&fit=crop",
  /cosmetic|beauty|makeup|shaver|trimmer/i =>
    "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800&h=800&fit=crop",
  /ring/i =>
    "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&h=800&fit=crop",
  /jewel|earring|necklace|bracelet|bangle/i =>
    "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&h=800&fit=crop",
  /accessor/i =>
    "https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=800&h=800&fit=crop"
}.freeze

DEFAULT_SUBCATEGORY_IMAGE =
  "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=800&fit=crop"

CATEGORY_IMAGES = {
  /cloth|stitch|fashion|women|men/i =>
    "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&h=800&fit=crop",
  /bag/i =>
    "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&h=800&fit=crop",
  /cosmetic|beauty/i =>
    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800&h=800&fit=crop",
  /jewel/i =>
    "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&h=800&fit=crop"
}.freeze

def normalize_category_name(name)
  case name.to_s.strip
  when /\AJewellery\z/i then "Jewelry"
  else name.to_s.strip
  end
end

def match_image(mapping, name, fallback)
  mapping.each do |pattern, url|
    return url if name.match?(pattern)
  end
  fallback
end

def attach_remote!(record, attachment_name, url, filename, replace: false)
  return if url.blank?

  attachment = record.public_send(attachment_name)
  return if !replace && attachment.attached? && !attachment.is_a?(ActiveStorage::Attached::Many)

  io = URI.open(
    url,
    "User-Agent" => "Mozilla/5.0",
    read_timeout: 60,
    open_timeout: 30
  )
  data = io.read
  content_type = io.respond_to?(:content_type) ? io.content_type.to_s : ""
  content_type = Marcel::MimeType.for(StringIO.new(data), name: filename) if content_type.blank? || content_type == "application/octet-stream"

  if attachment.is_a?(ActiveStorage::Attached::Many)
    attachment.attach(io: StringIO.new(data), filename: filename, content_type: content_type)
  else
    attachment.purge if replace && attachment.attached?
    return if attachment.attached?

    attachment.attach(io: StringIO.new(data), filename: filename, content_type: content_type)
  end
rescue StandardError => e
  warn "  ⚠ image failed (#{filename}): #{e.message}"
end

def ensure_attribute!(category:, name:, input_type:, required:, position:, options: [])
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

  attribute
end

def ensure_clothing_like_attributes!(category)
  ensure_attribute!(
    category: category,
    name: "Size",
    input_type: "select",
    required: true,
    position: 0,
    options: %w[XS S M L XL XXL] + ["Standard Size", "One Size", '22"', '23"']
  )
  ensure_attribute!(
    category: category,
    name: "Color",
    input_type: "select",
    required: true,
    position: 1,
    options: %w[Black White Blue Red Green Beige Pink Navy Grey Peach Multicolor Brown Purple Orange Yellow]
  )
end

def ensure_jewelry_attributes!(category)
  ensure_attribute!(
    category: category,
    name: "Ring Size",
    input_type: "select",
    required: false,
    position: 0,
    options: %w[6 7 8 9 10 11 12 Adjustable]
  )
  ensure_attribute!(
    category: category,
    name: "Color",
    input_type: "select",
    required: false,
    position: 1,
    options: ["Gold", "Silver", "Rose Gold", "Black", "White", "Red", "Multicolor"]
  )
end

def clothing_like?(category_name)
  category_name.match?(/cloth|stitch|fashion|women|men|kid/i)
end

def jewelry_like?(category_name)
  category_name.match?(/jewel/i)
end

def build_seo_title(title)
  base = "#{title} | Mahnira"
  base.length <= 70 ? base : "#{title.truncate(58, omission: "")} | Mahnira"
end

def build_seo_description(title, description, category_name, subcategory_name)
  snippet = description.to_s.squish
  snippet = snippet.split(/(?<=\.)\s+/).first(2).join(" ") if snippet.length > 140
  fallback = "Buy #{title} online at Mahnira. Shop #{subcategory_name.presence || category_name} with cash on delivery across Pakistan."
  text = snippet.presence || fallback
  text = "#{text} Order now at Mahnira." unless text.downcase.include?("mahnira")
  text.truncate(180, omission: "…")
end

def infer_color(title, description)
  colors = %w[Black White Blue Red Green Beige Pink Navy Grey Peach Brown Purple Orange Yellow Multicolor]
  haystack = "#{title} #{description}"
  colors.find { |color| haystack.match?(/\b#{Regexp.escape(color)}\b/i) } || "Multicolor"
end

def infer_size(title, description, subcategory_name)
  haystack = "#{title} #{description} #{subcategory_name}"
  return '22"' if haystack.match?(/22\s*"|chest\s*size\s*22/i)
  return '23"' if haystack.match?(/23\s*"|chest\s*size\s*23/i)
  return "One Size" if haystack.match?(/one size|free size|adjustable/i)
  return "Standard Size" if haystack.match?(/standard size/i)

  "Standard Size"
end

def ensure_option!(attribute, value)
  return if value.blank?

  option = attribute.category_attribute_options.find_or_initialize_by(value: value)
  option.position ||= attribute.category_attribute_options.count
  option.save!
end

created = 0
updated = 0
failed = []

puts "Importing #{products_data.size} Markaz products from #{json_path}..."

products_data.each_with_index do |data, index|
  source_id = data["source_id"]
  title = data["title"].to_s.strip
  puts "\n[#{index + 1}/#{products_data.size}] #{title} (#{source_id})"

  begin
    ActiveRecord::Base.transaction do
      category_name = normalize_category_name(data["category"])
      subcategory_name = data["subcategory"].to_s.strip.presence || "General"

      category = Category.find_or_initialize_by(name: category_name)
      if category.new_record?
        category.description = "Shop #{category_name} online at Mahnira."
        category.seo_title = "#{category_name} | Shop #{category_name} Online | Mahnira".truncate(70, omission: "")
        category.seo_description = "Shop #{category_name} online at Mahnira. Quality products with convenient delivery across Pakistan.".truncate(180, omission: "…")
      end
      category.save!

      if category.image.blank? && ENV["SKIP_SUBCATEGORY_IMAGES"].blank?
        attach_remote!(
          category,
          :image,
          match_image(CATEGORY_IMAGES, category_name, DEFAULT_SUBCATEGORY_IMAGE),
          "#{category_name.parameterize}.jpg"
        )
      end

      if clothing_like?(category_name)
        ensure_clothing_like_attributes!(category)
      elsif jewelry_like?(category_name)
        ensure_jewelry_attributes!(category)
      end

      subcategory = Subcategory.find_or_initialize_by(name: subcategory_name, category: category)
      subcategory.description ||= "Browse #{subcategory_name} in #{category_name} at Mahnira."
      subcategory.size_required = subcategory_name.match?(/\Arings?\z/i)
      subcategory.save!

      if subcategory.image.blank? && ENV["SKIP_SUBCATEGORY_IMAGES"].blank?
        attach_remote!(
          subcategory,
          :image,
          match_image(SUBCATEGORY_IMAGES, "#{category_name} #{subcategory_name}", DEFAULT_SUBCATEGORY_IMAGE),
          "#{subcategory_name.parameterize}.jpg"
        )
      end

      product = Product.find_or_initialize_by(title: title)
      was_new = product.new_record?
      product.assign_attributes(
        description: data["description"].to_s.strip.presence || title,
        price: data["price"],
        category: category,
        subcategory: subcategory,
        active: true,
        seo_title: build_seo_title(title),
        seo_description: build_seo_description(title, data["description"], category_name, subcategory_name)
      )
      product.save!

      # Refresh gallery images on every import so local/prod stay consistent.
      product.images.purge if product.images.attached?
      Array(data["images"]).each_with_index do |url, image_index|
        ext = File.extname(URI.parse(url).path).presence || ".jpg"
        attach_remote!(
          product,
          :images,
          url,
          "#{product.slug}-#{image_index + 1}#{ext}",
          replace: true
        )
      end

      cover_url = Array(data["images"]).first
      if cover_url.present?
        ext = File.extname(URI.parse(cover_url).path).presence || ".jpg"
        attach_remote!(product, :cover_image, cover_url, "#{product.slug}-cover#{ext}", replace: true)
      end

      sku = data["sku"].presence || "MZ-#{source_id}"
      variant = ProductVariant.find_or_initialize_by(sku: sku)
      variant.product = product
      variant.price = data["price"]
      variant.active = true

      attribute_values = {}
      if clothing_like?(category_name)
        size_attr = category.category_attributes.find_by(name: "Size")
        color_attr = category.category_attributes.find_by(name: "Color")
        size_value = infer_size(title, data["description"], subcategory_name)
        color_value = infer_color(title, data["description"])
        ensure_option!(size_attr, size_value)
        ensure_option!(color_attr, color_value)
        attribute_values[size_attr] = size_value
        attribute_values[color_attr] = color_value
      elsif jewelry_like?(category_name)
        ring_attr = category.category_attributes.find_by(name: "Ring Size")
        color_attr = category.category_attributes.find_by(name: "Color")
        if subcategory_name.match?(/ring/i) && ring_attr
          ensure_option!(ring_attr, "Adjustable")
          attribute_values[ring_attr] = "Adjustable"
        end
        if color_attr
          color_value = infer_color(title, data["description"])
          ensure_option!(color_attr, color_value)
          attribute_values[color_attr] = color_value
        end
      end

      if attribute_values.any?
        attribute_values.each do |attribute, value|
          record = variant.attribute_values.find { |item| item.category_attribute_id == attribute.id } ||
                   variant.attribute_values.build(category_attribute: attribute)
          record.value = value
        end
      else
        variant.name = "Standard"
      end

      variant.save!

      stock = data["stock"].to_i
      stock = 10 if stock.negative?
      variant.inventory.update!(quantity: stock, reserved_quantity: 0, threshold_level: [2, stock].min.clamp(1, 10))

      was_new ? created += 1 : updated += 1
      puts "  ✓ #{was_new ? 'created' : 'updated'} ##{product.id} | #{category_name} > #{subcategory_name} | Rs #{product.price} | images=#{product.images.count} cover=#{product.cover_image.attached?} stock=#{stock}"
      puts "  URL: #{product.public_url}"
    end
  rescue StandardError => e
    failed << { source_id: source_id, title: title, error: e.message }
    warn "  ✗ failed: #{e.message}"
  end
end

puts "\nDone. created=#{created} updated=#{updated} failed=#{failed.size}"
if failed.any?
  puts "Failures:"
  failed.each { |item| puts "  - #{item[:source_id]} #{item[:title]}: #{item[:error]}" }
  exit 1
end
