# frozen_string_literal: true

module DiscourseScholar
  class SearchController < BaseController
    MIN_QUERY_LENGTH = 3
    MAX_QUERY_LENGTH = 500

    def show
      return render_search_json if request.format.json? || request.xhr?

      render_page_shell
    end

    def autocomplete
      normalized_query = normalized_query_param
      if normalized_query.length < MIN_QUERY_LENGTH || normalized_query.length > MAX_QUERY_LENGTH
        return render json: DiscourseScholar::SearchPresenter.autocomplete_as_json({}, normalized_query)
      end

      with_upstream_error_handling do
        perform_rate_limit!("autocomplete")

        results = DiscourseScholar::SearchClient.new.autocomplete(normalized_query)

        render json: DiscourseScholar::SearchPresenter.autocomplete_as_json(results, normalized_query)
      end
    end

    private

    def render_search_json
      normalized_query = normalized_query_param
      page = [params[:page].to_i, 1].max
      per_page = DiscourseScholar::SearchClient::SEARCH_PAPER_LIMIT

      if normalized_query.blank? || normalized_query.length > MAX_QUERY_LENGTH
        return render json: DiscourseScholar::SearchPresenter.results_as_json({}, normalized_query, page: 1, per_page:)
      end

      with_upstream_error_handling do
        perform_rate_limit!("search")

        offset = (page - 1) * per_page
        results = DiscourseScholar::SearchClient.new.search(normalized_query, offset:)

        discourse_expires_in 2.minutes
        render json: DiscourseScholar::SearchPresenter.results_as_json(results, normalized_query, page:, per_page:)
      end
    end

    def normalized_query_param
      params[:q].to_s.strip.first(MAX_QUERY_LENGTH)
    end
  end
end
