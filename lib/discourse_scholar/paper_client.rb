# frozen_string_literal: true

module DiscourseScholar
  class PaperClient < BaseClient
    PATH = "v1/stc/papers/get"
    CITATIONS_PATH = "v1/stc/papers/citations"
    REFERENCES_PATH = "v1/stc/papers/references"
    RECOMMENDATIONS_PATH = "v1/stc/recommendations/paper"

    def fetch(paper_id)
      raise ResourceNotFound, I18n.t("discourse_scholar.errors.paper_not_found") if paper_id.blank?

      paper =
        post_json(PATH, {
          id: route_id(paper_id),
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        })

      raise ResourceNotFound, I18n.t("discourse_scholar.errors.paper_not_found") if paper.blank?

      paper
    end

    def fetch_citations(paper_id, limit: 10, offset: 0)
      post_json(
        CITATIONS_PATH,
        {
          paper_id: route_id(paper_id),
          fields: DiscourseScholar::RELATED_PAPER_FIELDS.join(","),
          limit: limit,
          offset: offset,
        },
      )
    end

    def fetch_references(paper_id, limit: 10, offset: 0)
      post_json(
        REFERENCES_PATH,
        {
          paper_id: route_id(paper_id),
          fields: DiscourseScholar::RELATED_PAPER_FIELDS.join(","),
          limit: limit,
          offset: offset,
        },
      )
    end

    def fetch_recommendations(paper_id, limit: 10)
      data =
        post_json(
          RECOMMENDATIONS_PATH,
          {
            paper_id: route_id(paper_id),
            fields: DiscourseScholar::RELATED_PAPER_FIELDS.join(","),
            limit: limit,
          },
        )

      if data.is_a?(Hash) && data["recommended_papers"]
        { "items" => data["recommended_papers"] }
      else
        data
      end
    end

    private

    def route_id(paper_id)
      paper_id.to_s.split(":", 2).last
    end
  end
end
