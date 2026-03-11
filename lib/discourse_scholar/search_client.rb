# frozen_string_literal: true

module DiscourseScholar
  class SearchClient < BaseClient
    SEARCH_PAPER_LIMIT = 20
    SEARCH_AUTHOR_LIMIT = 5
    AUTOCOMPLETE_PAPER_LIMIT = 5
    SEARCH_CACHE_TTL = 5.minutes
    AUTOCOMPLETE_CACHE_TTL = 2.minutes

    PAPER_SEARCH_PATH = "v1/stc/papers/search"
    AUTHOR_SEARCH_PATH = "v1/stc/authors/search"
    PAPER_AUTOCOMPLETE_PATH = "v1/stc/papers/autocomplete"

    def search(query, offset: 0)
      normalized_query = query.to_s.strip
      return { papers: [], authors: [], total: 0 } if normalized_query.blank?

      parallel_map(
        papers: -> { search_papers(normalized_query, limit: SEARCH_PAPER_LIMIT, offset:) },
        authors: -> { search_authors(normalized_query, limit: SEARCH_AUTHOR_LIMIT) },
      )
    end

    def autocomplete(query)
      normalized_query = query.to_s.strip
      return { papers: [], authors: [] } if normalized_query.blank?

      parallel_map(
        papers: -> { paper_autocomplete(normalized_query, limit: AUTOCOMPLETE_PAPER_LIMIT) },
        authors: -> { autocomplete_authors(normalized_query, limit: SEARCH_AUTHOR_LIMIT) },
      )
    end

    private

    def search_papers(query, limit:, offset: 0)
      data =
        cached_fetch(search_papers_cache_key(query, limit, offset), expires_in: SEARCH_CACHE_TTL) do
          post_json(PAPER_SEARCH_PATH, {
            query:,
            limit:,
            offset:,
            fields: DiscourseScholar::SEARCH_PAPER_FIELDS.join(","),
          }) || {}
        end

      { items: data["items"] || [], total: data["total"].to_i }
    end

    def search_authors(query, limit:)
      data =
        cached_fetch(search_authors_cache_key(query, limit), expires_in: SEARCH_CACHE_TTL) do
          post_json(AUTHOR_SEARCH_PATH, {
            query:,
            limit:,
            offset: 0,
            fields: DiscourseScholar::SEARCH_AUTHOR_FIELDS.join(","),
          }) || {}
        end

      data["items"] || []
    end

    def autocomplete_authors(query, limit:)
      data =
        cached_fetch(autocomplete_authors_cache_key(query, limit), expires_in: AUTOCOMPLETE_CACHE_TTL) do
          post_json(AUTHOR_SEARCH_PATH, {
            query:,
            limit:,
            offset: 0,
            fields: DiscourseScholar::AUTOCOMPLETE_AUTHOR_FIELDS.join(","),
          }) || {}
        end

      data["items"] || []
    end

    def paper_autocomplete(query, limit:)
      cached_fetch(paper_autocomplete_cache_key(query, limit), expires_in: AUTOCOMPLETE_CACHE_TTL) do
        post_json(PAPER_AUTOCOMPLETE_PATH, { query:, limit: }) || []
      end
    end

    def search_papers_cache_key(query, limit, offset)
      "discourse-scholar:upstream:stc:papers-search:#{query.downcase}:#{limit}:#{offset}"
    end

    def search_authors_cache_key(query, limit)
      "discourse-scholar:upstream:stc:authors-search:#{query.downcase}:#{limit}"
    end

    def autocomplete_authors_cache_key(query, limit)
      "discourse-scholar:upstream:stc:authors-autocomplete:#{query.downcase}:#{limit}"
    end

    def paper_autocomplete_cache_key(query, limit)
      "discourse-scholar:upstream:stc:papers-autocomplete:#{query.downcase}:#{limit}"
    end
  end
end
