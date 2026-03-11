# frozen_string_literal: true

require "uri"

module DiscourseScholar
  class BasePresenter
    private

    def value(object, *keys)
      keys.each do |key|
        string_key = key.to_s
        return object[string_key] if object.is_a?(Hash) && object.key?(string_key)
        return object[key.to_sym] if object.is_a?(Hash) && object.key?(key.to_sym)
      end

      nil
    end

    def safe_url(raw_value)
      return if raw_value.blank?

      uri = URI.parse(raw_value)
      return raw_value if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      nil
    end

    def route_id(raw_id)
      s = raw_id.to_s
      return s.split("/").last if s.include?("/")
      s.split(":", 2).last
    end

    def source_path_id(object)
      id = value(object, :id)
      source = value(object, :source)
      rid = route_id(id)
      source.present? && source != "stc" ? "#{source}:#{rid}" : rid
    end

    def count_value(object, *keys)
      keys.each do |key|
        raw = value(object, key)
        return raw.to_i if raw.present?
      end

      nil
    end
  end
end
