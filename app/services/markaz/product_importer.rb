# frozen_string_literal: true

require "open-uri"
require "stringio"

module Markaz
  class ProductImporter
    Result = Struct.new(:status, :product, :message, keyword_init: true)

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

    def self.call(data:, price: nil)
      new(data: data, price: price).call
    end

    def initialize(data:, price: nil)
      @data = data.stringify_keys
      @price = price.presence || @data["price"]
    end

    def call
      title = @data["title"].to_s.strip
      raise ArgumentError, "Product title is missing from the URL" if title.blank?
      raise ArgumentError, "Price must be greater than 0" if @price.to_d <= 0

      existing = find_existing_product(title)
      if existing
        return Result.new(
          status: :skipped,
          product: existing,
          message: "Product already exists: #{existing.title}"
        )
      end

      product = nil
      ActiveRecord::Base.transaction do
        category_name = normalize_category_name(@data["category"])
        subcategory_name = @data["subcategory"].to_s.strip.presence || "General"

        category = find_or_create_category!(category_name)
        subcategory = find_or_create_subcategory!(category, subcategory_name)

        product = Product.create!(
          title: title,
          description: @data["description"].to_s.strip.presence || title,
          price: @price.to_d,
          category: category,
          subcategory: subcategory,
          active: true,
          seo_title: build_seo_title(title),
          seo_description: build_seo_description(title, @data["description"], category_name, subcategory_name)
        )

        attach_product_images!(product)
        create_variant_and_inventory!(product, category, category_name, subcategory_name)
      end

      Result.new(
        status: :created,
        product: product,
        message: "Product imported successfully: #{product.title}"
      )
    end

    private

    def find_existing_product(title)
      sku = @data["sku"].to_s.strip
      source_id = @data["source_id"].to_s.strip

      by_title = Product.find_by(title: title)
      return by_title if by_title

      if sku.present?
        by_sku = Product.joins(:product_variants).find_by(product_variants: { sku: sku })
        return by_sku if by_sku
      end

      if source_id.present?
        Product.joins(:product_variants).find_by(product_variants: { sku: ["MZ-#{source_id}", source_id] })
      end
    end

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

    def find_or_create_category!(category_name)
      category = Category.find_or_initialize_by(name: category_name)
      if category.new_record?
        category.description = "Shop #{category_name} online at Mahnira."
        category.seo_title = "#{category_name} | Shop #{category_name} Online | Mahnira".truncate(70, omission: "")
        category.seo_description = "Shop #{category_name} online at Mahnira. Quality products with convenient delivery across Pakistan.".truncate(180, omission: "…")
        category.save!
      end

      unless category.image.attached?
        attach_remote!(
          category,
          :image,
          match_image(CATEGORY_IMAGES, category_name, DEFAULT_SUBCATEGORY_IMAGE),
          "#{category_name.parameterize}.jpg"
        )
      end

      if clothing_like?(category_name) || sized_category?(category_name) || scraped_sizes.any?
        ensure_size_and_color_attributes!(category, scraped_sizes)
      elsif jewelry_like?(category_name)
        ensure_jewelry_attributes!(category)
      end

      category
    end

    def scraped_sizes
      sizes = Array(@data["sizes"]).map { |size| size.to_s.strip }.reject(&:blank?)
      return sizes if sizes.any?

      Array(@data["size_variants"]).filter_map { |row| row["size"].to_s.strip.presence }
    end

    def find_or_create_subcategory!(category, subcategory_name)
      subcategory = Subcategory.find_or_initialize_by(name: subcategory_name, category: category)
      if subcategory.new_record? || scraped_sizes.any?
        subcategory.description ||= "Browse #{subcategory_name} in #{category.name} at Mahnira."
        subcategory.size_required = scraped_sizes.any? || subcategory_name.match?(/\Arings?\z/i)
        subcategory.save!
      end

      unless subcategory.image.attached?
        attach_remote!(
          subcategory,
          :image,
          match_image(SUBCATEGORY_IMAGES, "#{category.name} #{subcategory_name}", DEFAULT_SUBCATEGORY_IMAGE),
          "#{subcategory_name.parameterize}.jpg"
        )
      end

      subcategory
    end

    def attach_product_images!(product)
      Array(@data["images"]).each_with_index do |url, image_index|
        ext = File.extname(URI.parse(url).path).presence || ".jpg"
        attach_remote!(product, :images, url, "#{product.slug}-#{image_index + 1}#{ext}")
      end

      cover_url = Array(@data["images"]).first
      return if cover_url.blank?

      ext = File.extname(URI.parse(cover_url).path).presence || ".jpg"
      attach_remote!(product, :cover_image, cover_url, "#{product.slug}-cover#{ext}")
    end

    def create_variant_and_inventory!(product, category, category_name, subcategory_name)
      size_rows = size_variant_rows
      color_value = infer_color(product.title, @data["description"])

      if size_rows.any?
        ensure_size_and_color_attributes!(category, size_rows.map { |row| row["size"] })
        size_attr = category.category_attributes.find_by(name: "Size")
        color_attr = category.category_attributes.find_by(name: "Color")
        ensure_option!(color_attr, color_value) if color_attr

        size_rows.each do |row|
          size_value = row["size"].to_s
          sku = variant_sku_for(size_value)
          next if ProductVariant.exists?(sku: sku)

          ensure_option!(size_attr, size_value)
          variant = product.product_variants.build(
            sku: sku,
            price: (@price.presence || row["price"]).to_d,
            active: true,
            name: size_value
          )

          if size_attr
            variant.attribute_values.build(category_attribute: size_attr, value: size_value)
          end
          if color_attr && color_value.present?
            variant.attribute_values.build(category_attribute: color_attr, value: color_value)
          end

          variant.save!
          assign_inventory!(variant, row["stock"])
        end
        return
      end

      sku = @data["sku"].presence || "MZ-#{@data['source_id']}"
      raise ArgumentError, "A variant with SKU #{sku} already exists" if ProductVariant.exists?(sku: sku)

      variant = product.product_variants.build(
        sku: sku,
        price: @price.to_d,
        active: true,
        name: "Standard"
      )

      attribute_values = {}
      if clothing_like?(category_name) || sized_category?(category_name)
        size_attr = category.category_attributes.find_by(name: "Size")
        color_attr = category.category_attributes.find_by(name: "Color")
        size_value = infer_size(product.title, @data["description"], subcategory_name)
        ensure_option!(size_attr, size_value)
        ensure_option!(color_attr, color_value)
        attribute_values[size_attr] = size_value if size_attr
        attribute_values[color_attr] = color_value if color_attr
      elsif jewelry_like?(category_name)
        ring_attr = category.category_attributes.find_by(name: "Ring Size")
        color_attr = category.category_attributes.find_by(name: "Color")
        if subcategory_name.match?(/ring/i) && ring_attr
          ensure_option!(ring_attr, "Adjustable")
          attribute_values[ring_attr] = "Adjustable"
        end
        if color_attr
          ensure_option!(color_attr, color_value)
          attribute_values[color_attr] = color_value
        end
      end

      attribute_values.each do |attribute, value|
        variant.attribute_values.build(category_attribute: attribute, value: value)
      end

      variant.save!
      assign_inventory!(variant, @data["stock"])
    end

    def size_variant_rows
      rows = Array(@data["size_variants"]).filter_map do |row|
        size = row["size"].to_s.strip
        next if size.blank?

        {
          "size" => size,
          "price" => row["price"].presence || @price,
          "stock" => row["stock"].presence || @data["stock"] || 10
        }
      end
      return rows if rows.any?

      scraped_sizes.map do |size|
        {
          "size" => size,
          "price" => @price,
          "stock" => @data["stock"].presence || 10
        }
      end
    end

    def variant_sku_for(size_value)
      base = @data["sku"].presence || "MZ-#{@data['source_id']}"
      "#{base}-#{size_value.to_s.parameterize.upcase}"
    end

    def assign_inventory!(variant, stock_value)
      stock = stock_value.to_i
      stock = 10 if stock.negative?
      # Markaz sometimes reports placeholder stock like 100; keep a sensible shelf qty.
      stock = [@data["stock"].to_i, 10].max if stock > 50 && @data["stock"].to_i.positive?
      stock = 10 if stock > 50

      variant.inventory.update!(
        quantity: stock,
        reserved_quantity: 0,
        threshold_level: [2, stock].min.clamp(1, 10)
      )
    end

    def attach_remote!(record, attachment_name, url, filename)
      return if url.blank?

      attachment = record.public_send(attachment_name)
      return if !attachment.is_a?(ActiveStorage::Attached::Many) && attachment.attached?

      io = URI.open(url, "User-Agent" => "Mozilla/5.0", read_timeout: 60, open_timeout: 30)
      data = io.read
      content_type = io.respond_to?(:content_type) ? io.content_type.to_s : ""
      if content_type.blank? || content_type == "application/octet-stream"
        content_type = Marcel::MimeType.for(StringIO.new(data), name: filename)
      end

      attachment.attach(io: StringIO.new(data), filename: filename, content_type: content_type)
    rescue StandardError => e
      Rails.logger.warn("[Markaz::ProductImporter] image failed (#{filename}): #{e.message}")
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
      ensure_size_and_color_attributes!(category)
    end

    def ensure_size_and_color_attributes!(category, extra_sizes = [])
      default_sizes = %w[XS S M L XL XXL] + ["Standard Size", "One Size", '22"', '23"'] +
                      %w[36 37 38 39 40 41 42 43 44 45]
      ensure_attribute!(
        category: category,
        name: "Size",
        input_type: "select",
        required: true,
        position: 0,
        options: (default_sizes + Array(extra_sizes).map(&:to_s)).uniq
      )
      ensure_attribute!(
        category: category,
        name: "Color",
        input_type: "select",
        required: true,
        position: 1,
        options: %w[Black White Blue Red Green Beige Pink Navy Grey Peach Multicolor Brown Purple Orange Yellow Maroon]
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
        options: ["Gold", "Silver", "Rose Gold", "Black", "White", "Red", "Multicolor", "Maroon"]
      )
    end

    def clothing_like?(category_name)
      category_name.match?(/cloth|stitch|fashion|women|men|kid/i)
    end

    def sized_category?(category_name)
      category_name.match?(/shoe|pump|sandal|sneaker|footwear|apparel|dress/i)
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
      colors = %w[Black White Blue Red Green Beige Pink Navy Grey Peach Brown Purple Orange Yellow Maroon Multicolor]
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
      return if attribute.blank? || value.blank?

      option = attribute.category_attribute_options.find_or_initialize_by(value: value)
      option.position ||= attribute.category_attribute_options.count
      option.save!
    end
  end
end
