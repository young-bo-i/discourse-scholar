# frozen_string_literal: true

module DiscourseScholar
  class AuthorsController < BaseController
    def show
      return render_author_json if request.format.json? || request.xhr?

      render_page_shell
    end

    private

    def render_author_json
      perform_rate_limit!("author")

      author = cached_json(cache_key(params[:id])) do
        author_id = params[:id]
        author_thread = Thread.new { DiscourseScholar::AuthorClient.new.fetch(author_id) }
        papers_thread = Thread.new { DiscourseScholar::AuthorClient.new.fetch_papers(author_id, limit: 12) }

        {
          author: author_thread.value,
          papers: papers_thread.value,
        }
      end

      discourse_expires_in 5.minutes
      render json: DiscourseScholar::AuthorPresenter.new(author[:author], author[:papers]).as_json
    rescue DiscourseScholar::BaseClient::MissingConfiguration => e
      render_json_error(e.message, status: 503)
    rescue DiscourseScholar::BaseClient::ResourceNotFound => e
      render_json_error(e.message, status: 404)
    rescue DiscourseScholar::BaseClient::UpstreamError => e
      render_json_error(e.message, status: 502)
    end

    def cache_key(author_id)
      "discourse-scholar:author:#{author_id}"
    end
  end
end
