# frozen_string_literal: true

module DiscourseScholar
  class AuthorClient < BaseClient
    DETAIL_PATH = "v1/stc/authors/get"
    PAPERS_PATH = "v1/stc/authors/papers"

    def fetch(author_id)
      raise ResourceNotFound, I18n.t("discourse_scholar.errors.author_not_found") if author_id.blank?

      author =
        post_json(DETAIL_PATH, {
          id: route_id(author_id),
          fields: DiscourseScholar::AUTHOR_FIELDS.join(","),
        })

      raise ResourceNotFound, I18n.t("discourse_scholar.errors.author_not_found") if author.blank?

      author
    end

    def fetch_papers(author_id, limit: 12)
      post_json(PAPERS_PATH, {
        author_id: route_id(author_id),
        limit:,
        fields: DiscourseScholar::SEARCH_PAPER_FIELDS.join(","),
      }) || {}
    end

    def fetch_with_papers(author_id, papers_limit: 12)
      parallel_map(
        author: -> { fetch(author_id) },
        papers: -> { fetch_papers(author_id, limit: papers_limit) },
      )
    end
  end
end
