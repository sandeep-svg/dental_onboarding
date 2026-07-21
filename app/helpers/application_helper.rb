# frozen_string_literal: true
module ApplicationHelper
  def field_status_label(profile, field_name)
    value = profile.send(field_name)
    if value.present?
      if %w[completed processing].include?(profile.parsing_status)
        content_tag(:span, "Extracted from CV", class: "text-xs text-gray-400 ml-2")
      end
    elsif profile.parsing_status.present?
      content_tag(:span, "Missing", class: "text-xs text-red-500 ml-2")
    end
  end

  def field_uncertain_label(profile, field_name)
    value = profile.send(field_name)
    if value.present? && profile.parsing_status == "failed"
      content_tag(:span, "Please check", class: "text-xs text-amber-500 ml-2")
    end
  end

  def has_error_class(profile, field)
    profile.errors[field].any? ? "has-error" : ""
  end
end
