module AdminHelper
  def status_badge(status, type: :default)
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    
    case type
    when :user
      if status
        content_tag(:span, "Active", class: "#{base_classes} bg-green-light text-green-deep")
      else
        content_tag(:span, "Inactive", class: "#{base_classes} bg-red-100 text-red-800")
      end
    when :order
      status_str = status.to_s
      case status_str
      when "pending"
        content_tag(:span, "Pending", class: "#{base_classes} bg-yellow-100 text-yellow-800")
      when "accepted"
        content_tag(:span, "Accepted", class: "#{base_classes} bg-blue-100 text-blue-800")
      when "processing"
        content_tag(:span, "Processing", class: "#{base_classes} bg-purple-100 text-purple-800")
      when "shipped"
        content_tag(:span, "Shipped", class: "#{base_classes} bg-indigo-100 text-indigo-800")
      when "delivered"
        content_tag(:span, "Delivered", class: "#{base_classes} bg-green-light text-green-deep")
      when "canceled"
        content_tag(:span, "Canceled", class: "#{base_classes} bg-red-100 text-red-800")
      else
        content_tag(:span, status_str.humanize, class: "#{base_classes} bg-gray-100 text-gray-800")
      end
    when :active
      if status
        content_tag(:span, "Active", class: "#{base_classes} bg-green-light text-green-deep")
      else
        content_tag(:span, "Inactive", class: "#{base_classes} bg-red-100 text-red-800")
      end
    else
      content_tag(:span, status.to_s.humanize, class: "#{base_classes} bg-gray-100 text-gray-800")
    end
  end

  def role_badge(role)
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    if role == "admin"
      content_tag(:span, "Admin", class: "#{base_classes} bg-green-primary text-white")
    else
      content_tag(:span, "Customer", class: "#{base_classes} bg-blue-100 text-blue-800")
    end
  end

  def format_currency(amount)
    number_to_currency(amount, unit: "Rs", precision: 2)
  end

  def actions_dropdown(resource, resource_path)
    render partial: "admin/shared/actions_dropdown", locals: { resource: resource, resource_path: resource_path }
  end
end

