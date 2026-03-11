# frozen_string_literal: true

module DiscourseScholar
  class BaseController < ::ApplicationController
    CACHE_TTL = 10.minutes
    AUTOCOMPLETE_CACHE_TTL = 2.minutes
    ANON_RATE_LIMIT = 30
    ANON_RATE_LIMIT_PERIOD = 1.minute

    requires_plugin PLUGIN_NAME

    skip_before_action :check_xhr, :redirect_to_login_if_required

    before_action :ensure_plugin_enabled

    private

    def ensure_plugin_enabled
      raise Discourse::NotFound unless SiteSetting.discourse_scholar_enabled
    end

    def render_page_shell
      render "default/empty"
    end

    def perform_rate_limit!(scope)
      RateLimiter.new(
        nil,
        "discourse-scholar-#{scope}-#{request.remote_ip}",
        ANON_RATE_LIMIT,
        ANON_RATE_LIMIT_PERIOD,
      ).performed!
    end

    def cached_json(cache_key, expires_in: CACHE_TTL, rate_limit_scope: nil)
      Rails.cache.fetch(cache_key, expires_in:) do
        perform_rate_limit!(rate_limit_scope) if rate_limit_scope
        yield
      end
    end

    def with_upstream_error_handling
      yield
    rescue DiscourseScholar::BaseClient::MissingConfiguration => e
      render_json_error(e.message, status: 503)
    rescue DiscourseScholar::BaseClient::ResourceNotFound => e
      render_json_error(e.message, status: 404)
    rescue DiscourseScholar::BaseClient::UpstreamError => e
      render_json_error(e.message, status: 502)
    end
  end
end
