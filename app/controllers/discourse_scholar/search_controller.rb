# frozen_string_literal: true

module DiscourseScholar
  class SearchController < BaseController
    MIN_AUTOCOMPLETE_QUERY_LENGTH = 2

    def show
      return render_search_json if request.format.json? || request.xhr?

      render_page_shell
    end

    def autocomplete
      normalized_query = normalized_query_param
      return render json: DiscourseScholar::SearchPresenter.autocomplete_as_json({}, normalized_query) if normalized_query.length < MIN_AUTOCOMPLETE_QUERY_LENGTH

      perform_rate_limit!("autocomplete")

      results = cached_json(autocomplete_cache_key, expires_in: AUTOCOMPLETE_CACHE_TTL) do
        DiscourseScholar::SearchClient.new.autocomplete(normalized_query)
      end

      render json: DiscourseScholar::SearchPresenter.autocomplete_as_json(results, normalized_query)
    rescue DiscourseScholar::BaseClient::MissingConfiguration => e
      render_json_error(e.message, status: 503)
    rescue DiscourseScholar::BaseClient::UpstreamError => e
      render_json_error(e.message, status: 502)
    end

    private

    def render_search_json
      normalized_query = normalized_query_param
      return render json: DiscourseScholar::SearchPresenter.results_as_json({}, normalized_query) if normalized_query.blank?

      perform_rate_limit!("search")

      results = cached_json(search_cache_key(normalized_query)) { DiscourseScholar::SearchClient.new.search(normalized_query) }

      discourse_expires_in 2.minutes
      render json: DiscourseScholar::SearchPresenter.results_as_json(results, normalized_query)
    rescue DiscourseScholar::BaseClient::MissingConfiguration => e
      render_json_error(e.message, status: 503)
    rescue DiscourseScholar::BaseClient::UpstreamError => e
      render_json_error(e.message, status: 502)
    end

    def autocomplete_cache_key
      "discourse-scholar:autocomplete:#{normalized_query_param.downcase}"
    end

    def search_cache_key(query)
      "discourse-scholar:search:#{query.downcase}"
    end

    def normalized_query_param
      params[:q].to_s.strip
    end
  end
end
