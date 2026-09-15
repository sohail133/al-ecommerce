# frozen_string_literal: true

class Admin::ProductImportsController < Admin::BaseController
  def create
    source_url = import_params[:source_url].to_s.strip
    price = import_params[:price]

    scraped = Markaz::ProductScraper.call(source_url)
    result = Markaz::ProductImporter.call(data: scraped, price: price)

    case result.status
    when :created
      redirect_to admin_product_path(result.product), notice: result.message
    when :skipped
      redirect_to admin_product_path(result.product), alert: result.message
    else
      redirect_back fallback_location: admin_products_path, alert: result.message
    end
  rescue Markaz::ProductScraper::Error, ArgumentError => e
    redirect_back fallback_location: admin_products_path, alert: e.message
  rescue StandardError => e
    Rails.logger.error("[Admin::ProductImportsController] #{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}")
    redirect_back fallback_location: admin_products_path, alert: "Import failed. Please try again."
  end

  private

  def import_params
    params.require(:product_import).permit(:source_url, :price)
  end
end
