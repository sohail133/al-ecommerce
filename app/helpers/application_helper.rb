module ApplicationHelper
  def user_avatar(user, size: 10, class_names: "")
    return "" unless user
    initial = user.full_name&.first&.upcase || user.email&.first&.upcase || "U"
    size_class = case size
                 when 8 then "h-8 w-8"
                 when 10 then "h-10 w-10"
                 when 12 then "h-12 w-12"
                 else "h-10 w-10"
                 end
    content_tag(:div, initial, class: "user-avatar #{size_class} text-sm #{class_names}")
  end
end
