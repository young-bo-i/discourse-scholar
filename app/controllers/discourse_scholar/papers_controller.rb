# frozen_string_literal: true

module DiscourseScholar
  class PapersController < BaseController
    def show
      return render_paper_json if request.format.json? || request.xhr?

      render_page_shell
    end

    def citations
      render_related_papers(:citations) do |client, paper_id|
        client.fetch_citations(paper_id, limit: 10)
      end
    end

    def references
      render_related_papers(:references) do |client, paper_id|
        client.fetch_references(paper_id, limit: 10)
      end
    end

    def related
      render_related_papers(:related) do |client, paper_id|
        client.fetch_recommendations(paper_id, limit: 10)
      end
    end

    private

    def render_paper_json
      with_upstream_error_handling do
        paper = cached_json(cache_key(params[:id]), rate_limit_scope: "paper") do
          DiscourseScholar::PaperClient.new.fetch(params[:id])
        end

        discourse_expires_in 5.minutes
        render json: DiscourseScholar::PaperPresenter.new(paper).as_json
      end
    end

    def render_related_papers(kind)
      with_upstream_error_handling do
        data = cached_json("discourse-scholar:paper:#{kind}:#{params[:id]}", rate_limit_scope: "paper_#{kind}") do
          yield DiscourseScholar::PaperClient.new, params[:id]
        end

        items = data.is_a?(Hash) ? (data["items"] || data[:items] || []) : Array(data)
        papers = DiscourseScholar::SearchPresenter.papers_as_json(items)

        discourse_expires_in 5.minutes
        render json: { papers: papers }
      end
    end

    def cache_key(paper_id)
      "discourse-scholar:paper:#{paper_id}"
    end
  end
end
