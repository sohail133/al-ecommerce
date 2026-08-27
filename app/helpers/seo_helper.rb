# frozen_string_literal: true

module SeoHelper
  BRAND = Site::BRAND

  # Renders title, description, canonical, robots, Open Graph and Twitter tags.
  def seo_tags(
    title:,
    description:,
    canonical: nil,
    image: nil,
    type: "website",
    robots: nil,
    noindex: false,
    og_title: nil,
    og_description: nil
  )
    full_title = title.to_s
    desc = truncate_meta(description)
    canonical_url = canonical.presence || request_canonical_url
    image_url = absolute_seo_image(image)
    robots_content = robots.presence || (noindex ? "noindex, follow" : "index, follow")

    tags = []
    tags << tag.title(full_title)
    tags << tag.meta(name: "description", content: desc) if desc.present?
    tags << tag.meta(name: "robots", content: robots_content)
    tags << tag.link(rel: "canonical", href: canonical_url)

    tags << tag.meta(property: "og:site_name", content: BRAND)
    tags << tag.meta(property: "og:locale", content: Site::LOCALE)
    tags << tag.meta(property: "og:type", content: type)
    tags << tag.meta(property: "og:title", content: og_title.presence || full_title)
    tags << tag.meta(property: "og:description", content: og_description.presence || desc) if desc.present?
    tags << tag.meta(property: "og:url", content: canonical_url)
    tags << tag.meta(property: "og:image", content: image_url) if image_url.present?

    tags << tag.meta(name: "twitter:card", content: "summary_large_image")
    tags << tag.meta(name: "twitter:title", content: og_title.presence || full_title)
    tags << tag.meta(name: "twitter:description", content: og_description.presence || desc) if desc.present?
    tags << tag.meta(name: "twitter:image", content: image_url) if image_url.present?

    safe_join(tags, "\n")
  end

  def json_ld(data)
    return "".html_safe if data.blank?

    content_tag(:script, data.to_json.html_safe, type: "application/ld+json")
  end

  def organization_json_ld
    setting = StoreSetting.instance
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => BRAND,
      "url" => Site.url,
      "logo" => Site.absolute_url(Site::DEFAULT_OG_IMAGE),
      "email" => setting.email,
      "telephone" => setting.phone_number,
      "address" => {
        "@type" => "PostalAddress",
        "addressCountry" => "PK",
        "streetAddress" => setting.location
      }.compact,
      "sameAs" => [setting.facebook_url, setting.instagram_url, setting.youtube_url, setting.whatsapp_chat_url].compact_blank
    }.compact
  end

  def website_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => BRAND,
      "url" => Site.url,
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => {
          "@type" => "EntryPoint",
          "urlTemplate" => "#{Site.url}/products?name={search_term_string}"
        },
        "query-input" => "required name=search_term_string"
      }
    }
  end

  def breadcrumb_json_ld(items)
    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => items.each_with_index.map do |item, index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => item[:name],
          "item" => item[:url]
        }
      end
    }
  end

  def product_json_ld(product)
    variant = product.product_variants.find { |v| v.active? } || product.product_variants.first
    price = variant&.price || product.price
    sku = variant&.sku
    availability = product_schema_availability(variant)
    image = absolute_seo_image(seo_product_image(product))
    description = truncate_meta(product.seo_page_description)

    data = {
      "@context" => "https://schema.org",
      "@type" => "Product",
      "name" => product.title,
      "description" => description,
      "brand" => {
        "@type" => "Brand",
        "name" => BRAND
      },
      "url" => Site.absolute_url(product_path(product)),
      "image" => [image].compact,
      "sku" => sku,
      "category" => product.category&.name,
      "offers" => {
        "@type" => "Offer",
        "url" => Site.absolute_url(product_path(product)),
        "priceCurrency" => Site::CURRENCY,
        "price" => format("%.2f", price.to_d),
        "availability" => availability,
        "itemCondition" => "https://schema.org/NewCondition",
        "seller" => {
          "@type" => "Organization",
          "name" => BRAND
        }
      }
    }

    rating = product.average_rating
    count = product.review_count
    if count.to_i.positive? && rating.to_f.positive?
      data["aggregateRating"] = {
        "@type" => "AggregateRating",
        "ratingValue" => rating,
        "reviewCount" => count
      }
    end

    data.compact
  end

  def collection_page_json_ld(name:, description:, url:, products: [])
    {
      "@context" => "https://schema.org",
      "@type" => "CollectionPage",
      "name" => name,
      "description" => truncate_meta(description),
      "url" => url,
      "isPartOf" => {
        "@type" => "WebSite",
        "name" => BRAND,
        "url" => Site.url
      },
      "mainEntity" => {
        "@type" => "ItemList",
        "itemListElement" => Array(products).first(20).each_with_index.map do |product, index|
          {
            "@type" => "ListItem",
            "position" => index + 1,
            "url" => Site.absolute_url(product_path(product)),
            "name" => product.title
          }
        end
      }
    }
  end

  def seo_product_image(product)
    return product.cover_image if product.cover_image.attached?
    return product.images.first if product.images.attached?

    nil
  end

  def seo_image_tag(source, alt:, loading: "lazy", fetchpriority: nil, css_class: nil, **options)
    opts = options.merge(alt: alt, loading: loading)
    opts[:class] = css_class if css_class.present?
    opts[:fetchpriority] = fetchpriority if fetchpriority.present?

    return if source.blank?
    return if source.respond_to?(:attached?) && !source.attached?

    if source.respond_to?(:variant)
      begin
        image_tag(source.variant(resize_to_limit: [1200, 1200]), **opts)
      rescue StandardError
        image_tag(source, **opts)
      end
    else
      image_tag(source, **opts)
    end
  end

  def listing_has_indexable_filters?
    %i[name category_id subcategory_id min_price max_price].any? { |key| params[key].present? } ||
      (params[:sort].present? && params[:sort] != "newest")
  end

  def products_index_canonical_path
    if params[:sort] == "newest" && !%i[name category_id subcategory_id min_price max_price].any? { |k| params[k].present? }
      new_arrivals_path
    else
      products_path
    end
  end

  private

  def truncate_meta(text, length: 160)
    return "" if text.blank?

    sanitized = strip_tags(text.to_s).squish
    truncate(sanitized, length: length, separator: " ", omission: "…")
  end

  def request_canonical_url
    Site.absolute_url(request.path)
  end

  def absolute_seo_image(image)
    return Site.absolute_url(Site::DEFAULT_OG_IMAGE) if image.blank?

    if image.is_a?(String)
      return Site.absolute_url(image)
    end

    if image.respond_to?(:attached?) && !image.attached?
      return Site.absolute_url(Site::DEFAULT_OG_IMAGE)
    end

    begin
      rails_blob_url(image, host: Site.host, protocol: URI.parse(Site.url).scheme)
    rescue StandardError
      begin
        url_for(image)
      rescue StandardError
        Site.absolute_url(Site::DEFAULT_OG_IMAGE)
      end
    end
  end

  def product_schema_availability(variant)
    inventory = variant&.inventory
    if inventory.nil?
      "https://schema.org/InStock"
    elsif inventory.available_quantity.to_i.positive?
      "https://schema.org/InStock"
    else
      "https://schema.org/OutOfStock"
    end
  end
end
