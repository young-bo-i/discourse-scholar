# frozen_string_literal: true

module DiscourseScholar
  class PaperClient < BaseClient
    PATH = "v1/stc/papers/get"

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

    private

    def route_id(paper_id)
      paper_id.to_s.split(":", 2).last
    end
  end
end
