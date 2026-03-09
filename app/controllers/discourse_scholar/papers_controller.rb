# frozen_string_literal: true

module DiscourseScholar
  class PapersController < BaseController
    def show
      return render_paper_json if request.format.json? || request.xhr?

      render_page_shell
    end

    private

    def render_paper_json
      perform_rate_limit!("paper")

      paper = cached_json(cache_key(params[:id])) do
        DiscourseScholar::PaperClient.new.fetch(params[:id])
      end

      discourse_expires_in 5.minutes
      render json: DiscourseScholar::PaperPresenter.new(paper).as_json
    rescue DiscourseScholar::BaseClient::MissingConfiguration => e
      render_json_error(e.message, status: 503)
    rescue DiscourseScholar::BaseClient::ResourceNotFound => e
      render_json_error(e.message, status: 404)
    rescue DiscourseScholar::BaseClient::UpstreamError => e
      render_json_error(e.message, status: 502)
    end

    def cache_key(paper_id)
      "discourse-scholar:paper:#{paper_id}"
    end
  end
end
