# frozen_string_literal: true

require "json"
require "uri"

module DiscourseScholar
  class BaseClient
    ALLOWED_HOSTS = %w[open.scholay.com].freeze
    OPEN_TIMEOUT_SECONDS = 5
    READ_TIMEOUT_SECONDS = 15

    class Error < StandardError; end
    class MissingConfiguration < Error; end
    class ResourceNotFound < Error; end
    class UpstreamError < Error; end

    CONNECTION_MUTEX = Mutex.new

    def self.reset_connection!
      CONNECTION_MUTEX.synchronize do
        @shared_connection = nil
        @cached_base_url = nil
      end
    end

    def self.shared_connection
      CONNECTION_MUTEX.synchronize do
        base_url = validated_base_url
        if @shared_connection.nil? || @cached_base_url != base_url
          @cached_base_url = base_url
          @shared_connection =
            Faraday.new(
              url: base_url,
              request: {
                open_timeout: OPEN_TIMEOUT_SECONDS,
                timeout: READ_TIMEOUT_SECONDS,
              },
            )
        end
        @shared_connection
      end
    end

    def self.api_key
      key =
        ENV["DISCOURSE_SCHOLAR_API_KEY"].presence || SiteSetting.discourse_scholar_api_key
      if key.blank?
        raise MissingConfiguration, I18n.t("discourse_scholar.errors.missing_api_key")
      end
      key
    end

    def self.validated_base_url
      uri = URI.parse(SiteSetting.discourse_scholar_api_base_url)
      host = uri.host&.downcase

      if !uri.is_a?(URI::HTTPS) || host.blank? || !ALLOWED_HOSTS.include?(host) || uri.user ||
           uri.password || uri.query || uri.fragment
        raise MissingConfiguration, I18n.t("discourse_scholar.errors.invalid_base_url")
      end

      base_url = "#{uri.scheme}://#{host}"
      base_url += ":#{uri.port}" if uri.port.present? && uri.port != 443

      normalized_path = uri.path.presence == "/" ? nil : uri.path.presence&.sub(%r{/*$}, "")
      base_url += normalized_path if normalized_path.present?

      base_url
    rescue URI::InvalidURIError
      raise MissingConfiguration, I18n.t("discourse_scholar.errors.invalid_base_url")
    end

    protected

    def post_json(path, body)
      response =
        BaseClient.shared_connection.post(path) do |request|
          request.headers["Content-Type"] = "application/json"
          request.headers["Accept"] = "application/json"
          request.headers["Authorization"] = "Bearer #{BaseClient.api_key}"
          request.body = body.to_json
        end

      parsed = parse_json(response.body)
      raise_error_from_response!(response, parsed)
      parsed.fetch("data", nil)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise UpstreamError, "#{I18n.t("discourse_scholar.errors.upstream_unavailable")} (#{e.class.name})"
    end

    def cached_fetch(cache_key, expires_in: 5.minutes)
      Rails.cache.fetch(cache_key, expires_in:) { yield }
    end

    def parallel_map(tasks)
      threads =
        tasks.map do |key, task|
          Thread.new do
            [key, task.call]
          rescue StandardError => e
            [key, e]
          end
        end

      threads.to_h do |thread|
        key, value = thread.value
        raise value if value.is_a?(StandardError)

        [key, value]
      end
    end

    def route_id(raw_id)
      raw_id.to_s.split(":", 2).last
    end

    private

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError
      raise UpstreamError, I18n.t("discourse_scholar.errors.invalid_response")
    end

    def raise_error_from_response!(response, parsed)
      if response.status == 404
        raise ResourceNotFound, I18n.t("discourse_scholar.errors.not_found")
      end

      message = extract_error_message(parsed)
      not_found = message&.match?(/not found|no paper|no author/i)

      if response.status >= 400 || (parsed["code"].present? && parsed["code"] != 0) ||
           parsed["success"] == false
        raise(not_found ? ResourceNotFound : UpstreamError,
              message.presence || I18n.t("discourse_scholar.errors.upstream_error"))
      end
    end

    def extract_error_message(parsed)
      error = parsed["error"]
      return error["message"] if error.is_a?(Hash)
      return error if error.is_a?(String)

      parsed["message"]
    end
  end
end
