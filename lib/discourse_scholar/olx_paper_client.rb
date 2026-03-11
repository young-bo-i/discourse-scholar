# frozen_string_literal: true

module DiscourseScholar
  class OlxPaperClient < BaseClient
    PATH = "v1/olx/works/get"
    CITATIONS_PATH = "v1/olx/works/citations"
    REFERENCES_PATH = "v1/olx/works/references"
    RELATED_PATH = "v1/olx/works/related"

    def fetch(paper_id)
      raise ResourceNotFound, I18n.t("discourse_scholar.errors.paper_not_found") if paper_id.blank?

      paper = post_json(PATH, { id: route_id(paper_id) })

      raise ResourceNotFound, I18n.t("discourse_scholar.errors.paper_not_found") if paper.blank?

      paper
    end

    def fetch_citations(paper_id, limit: 10, offset: 0)
      post_json(CITATIONS_PATH, { paper_id: route_id(paper_id), limit: limit, offset: offset })
    end

    def fetch_references(paper_id, limit: 10, offset: 0)
      post_json(REFERENCES_PATH, { paper_id: route_id(paper_id), limit: limit, offset: offset })
    end

    def fetch_recommendations(paper_id, limit: 10)
      post_json(RELATED_PATH, { work_id: route_id(paper_id), limit: limit })
    end
  end
end
