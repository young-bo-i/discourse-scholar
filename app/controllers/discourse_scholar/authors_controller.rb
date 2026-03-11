# frozen_string_literal: true

module DiscourseScholar
  class AuthorsController < BaseController
    def show
      return render_author_json if request.format.json? || request.xhr?

      render_page_shell
    end

    private

    def render_author_json
      source, id = DiscourseScholar::SourceResolver.resolve(params[:id])

      with_upstream_error_handling do
        author = cached_json("discourse-scholar:author:#{source}:#{id}", rate_limit_scope: "author") do
          DiscourseScholar::SourceResolver.author_client(source).fetch_with_papers(id)
        end

        discourse_expires_in 5.minutes
        render json: DiscourseScholar::AuthorPresenter.new(author[:author], author[:papers]).as_json
      end
    end
  end
end
