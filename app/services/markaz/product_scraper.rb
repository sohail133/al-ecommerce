# frozen_string_literal: true

require "net/http"
require "json"
require "cgi"

module Markaz
  class ProductScraper
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    URL_PATTERN = %r{\Ahttps?://(?:www\.)?markaz\.app/shop/product/(?:p/|[^/]+/)(?<id>\d+)/?\z}i

    class Error < StandardError; end

    def self.call(url)
      new(url).call
    end

    def initialize(url)
      @url = url.to_s.strip
    end

    def call
      raise Error, "Product URL is required" if @url.blank?
      raise Error, "Only Markaz product URLs are supported right now" unless (match = @url.match(URL_PATTERN))

      source_id = match[:id]
      html = fetch_html(canonical_url(source_id))
      blocks = parse_json_ld(html)
      product = blocks.find { |block| block["@type"] == "Product" }
      raise Error, "Could not read product details from this URL" if product.blank?

      category, subcategory = breadcrumb_names(blocks)
      if product["category"].present? && (category.blank? || subcategory.blank?)
        parts = product["category"].to_s.split(">").map(&:strip)
        category ||= parts[0]
        subcategory ||= parts[1]
      end

      offers = product["offers"]
      offers = offers.first if offers.is_a?(Array)
      offers = {} unless offers.is_a?(Hash)

      images = image_urls(product["image"])
      if images.size < 2
        extra = html.tr('\\"', '"').scan(
          %r{https://static\.markaz\.app/pakistan/products/[^"\\\s]*#{Regexp.escape(source_id)}-product-\d+\.(?:webp|jpg|jpeg|png)}i
        ).uniq
        extra.each do |image_url|
          next if image_url.downcase.include?("withcode")
          images << image_url unless images.include?(image_url)
        end
      end

      size_variants = extract_size_variants(html)
      sizes = size_variants.map { |row| row["size"] }
      sizes = extract_available_sizes(html, product["description"].to_s) if sizes.empty?

      {
        "source_id" => source_id,
        "source_url" => canonical_url(source_id),
        "title" => CGI.unescapeHTML(product["name"].to_s).strip,
        "description" => CGI.unescapeHTML(product["description"].to_s).strip,
        "price" => offers["price"].to_s.gsub(",", "").to_d,
        "sku" => (product["sku"].presence || product["mpn"].presence || "MZ-#{source_id}").to_s.strip,
        "stock" => stock_from_page(html, offers["availability"]),
        "category" => category.presence || "General",
        "subcategory" => subcategory.presence || "General",
        "images" => images,
        "sizes" => sizes,
        "size_variants" => size_variants,
        "markaz_category_path" => product["category"],
        "brand" => product.dig("brand", "name")
      }
    end

    private

    def canonical_url(source_id)
      "https://www.markaz.app/shop/product/p/#{source_id}"
    end

    def fetch_html(url)
      uri = URI.parse(url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 20, read_timeout: 45) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = USER_AGENT
        request["Accept"] = "text/html"
        http.request(request)
      end

      raise Error, "Markaz returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body.to_s.force_encoding("UTF-8")
    rescue Error
      raise
    rescue StandardError => e
      raise Error, "Could not fetch product page: #{e.message}"
    end

    def parse_json_ld(html)
      html.scan(%r{<script type="application/ld\+json">(.*?)</script>}m).filter_map do |match|
        raw = match.first
        JSON.parse(raw)
      rescue JSON::ParserError
        JSON.parse(CGI.unescapeHTML(raw))
      rescue JSON::ParserError
        nil
      end
    end

    def breadcrumb_names(blocks)
      crumb = blocks.find { |block| block["@type"] == "BreadcrumbList" }
      return [nil, nil] unless crumb

      names = Array(crumb["itemListElement"]).filter_map { |item| item["name"] if item.is_a?(Hash) }
      category = names[2]
      subcategory = names.size > 4 ? names[3] : nil
      [category, subcategory]
    end

    def image_urls(images)
      list = case images
             when String then [images]
             when Array then images
             else []
             end

      list.filter_map do |url|
        next unless url.is_a?(String)
        next if url.downcase.end_with?(".mp4", ".webm", ".mov")
        next if url.downcase.include?("withcode")

        url
      end.uniq
    end

    def stock_from_page(html, availability)
      # Markaz often renders "Only <!-- -->3<!-- --> left" in the HTML.
      normalized = html.to_s.gsub(/<!--.*?-->/m, " ")

      if (match = normalized.match(/Only\s+(\d+)\s+left/i))
        return match[1].to_i
      end
      if (match = normalized.match(/(\d+)\s+in stock/i))
        return match[1].to_i
      end
      return 0 if availability.to_s.include?("OutOfStock")

      10
    end

    # Markaz embeds selectable sizes like: "options":{"Size":"36"},"price":2339,...,"stock":100
    def extract_size_variants(html)
      text = html.to_s.tr('\\"', '"')
      rows = text.scan(
        /"options"\s*:\s*\{\s*"Size"\s*:\s*"([^"]+)"\s*\}\s*,\s*"price"\s*:\s*(\d+)\s*,\s*"oldPrice"\s*:\s*\d+\s*,\s*"discount"\s*:\s*\d+\s*,\s*"stock"\s*:\s*(\d+)/i
      )

      rows.filter_map do |size, price, stock|
        next if size.blank?

        {
          "size" => size.to_s.strip,
          "price" => price.to_d,
          "stock" => stock.to_i
        }
      end.uniq { |row| row["size"] }
    end

    def extract_available_sizes(html, description)
      text = "#{html} #{description}".tr('\\"', '"')
      if (match = text.match(/Available Sizes:\s*([0-9A-Za-z\-,\s\/]+)/i))
        return match[1].split(/[,\/]/).map { |part| part.to_s.strip }.reject(&:blank?).uniq
      end

      []
    end
  end
end
