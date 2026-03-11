# frozen_string_literal: true

module DiscourseScholar
  class AuthorsController < BaseController
    def show
      return render_author_json if request.format.json? || request.xhr?

      render_page_shell
    end

    private

    def render_author_json
      with_upstream_error_handling do
        author = cached_json(cache_key(params[:id]), rate_limit_scope: "author") do
          DiscourseScholar::AuthorClient.new.fetch_with_papers(params[:id])
        end

        discourse_expires_in 5.minutes
        render json: DiscourseScholar::AuthorPresenter.new(author[:author], author[:papers]).as_json
      end
    end

    def cache_key(author_id)
      "discourse-scholar:author:#{author_id}"
    end
  end
end
