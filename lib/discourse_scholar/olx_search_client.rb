# frozen_string_literal: true

module DiscourseScholar
  class OlxSearchClient < BaseClient
    SEARCH_PAPER_LIMIT = 20
    SEARCH_AUTHOR_LIMIT = 5
    AUTOCOMPLETE_PAPER_LIMIT = 5
    SEARCH_CACHE_TTL = 5.minutes
    AUTOCOMPLETE_CACHE_TTL = 2.minutes

    PAPER_SEARCH_PATH = "v1/olx/works/search"
    AUTHOR_SEARCH_PATH = "v1/olx/authors/search"
    PAPER_AUTOCOMPLETE_PATH = "v1/olx/works/autocomplete"
    AUTHOR_AUTOCOMPLETE_PATH = "v1/olx/authors/autocomplete"

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
        authors: -> { author_autocomplete(normalized_query, limit: SEARCH_AUTHOR_LIMIT) },
      )
    end

    private

    def search_papers(query, limit:, offset: 0)
      data =
        cached_fetch(cache_key("olx:papers-search", query, limit, offset), expires_in: SEARCH_CACHE_TTL) do
          post_json(PAPER_SEARCH_PATH, { query:, limit:, page: offset > 0 ? (offset / limit) + 1 : 1 }) || {}
        end

      { items: data["items"] || [], total: data["total"].to_i }
    end

    def search_authors(query, limit:)
      data =
        cached_fetch(cache_key("olx:authors-search", query, limit), expires_in: SEARCH_CACHE_TTL) do
          post_json(AUTHOR_SEARCH_PATH, { query:, limit: }) || {}
        end

      data["items"] || []
    end

    def paper_autocomplete(query, limit:)
      cached_fetch(cache_key("olx:papers-autocomplete", query, limit), expires_in: AUTOCOMPLETE_CACHE_TTL) do
        data = post_json(PAPER_AUTOCOMPLETE_PATH, { query: }) || {}
        normalize_olx_autocomplete_items(data["items"] || [], limit)
      end
    end

    def author_autocomplete(query, limit:)
      cached_fetch(cache_key("olx:authors-autocomplete", query, limit), expires_in: AUTOCOMPLETE_CACHE_TTL) do
        data = post_json(AUTHOR_AUTOCOMPLETE_PATH, { query: }) || {}
        normalize_olx_author_autocomplete_items(data["items"] || [], limit)
      end
    end

    def normalize_olx_autocomplete_items(items, limit)
      Array(items).first(limit).filter_map do |item|
        id = extract_olx_id(item["id"])
        title = item["display_name"]
        next if id.blank? || title.blank?

        { "id" => id, "source" => "olx", "title" => title }
      end
    end

    def normalize_olx_author_autocomplete_items(items, limit)
      Array(items).first(limit).filter_map do |item|
        id = extract_olx_id(item["id"])
        name = item["display_name"]
        next if id.blank? || name.blank?

        affiliations = item["hint"].present? ? [item["hint"]] : []
        { "id" => id, "source" => "olx", "name" => name, "affiliations" => affiliations }
      end
    end

    def extract_olx_id(raw_id)
      return if raw_id.blank?

      if raw_id.include?("/")
        raw_id.split("/").last
      else
        raw_id
      end
    end

    def cache_key(prefix, query, *parts)
      "discourse-scholar:upstream:#{prefix}:#{query.downcase}:#{parts.join(":")}"
    end
  end
end
