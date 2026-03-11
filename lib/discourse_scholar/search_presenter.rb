# frozen_string_literal: true

module DiscourseScholar
  class SearchPresenter < BasePresenter
    class << self
      def results_as_json(results, query, page: 1, per_page: 10)
        new.results_as_json(results, query, page:, per_page:)
      end

      def autocomplete_as_json(results, query)
        new.autocomplete_as_json(results, query)
      end

      def papers_as_json(items)
        new.normalize_paper_list(items)
      end
    end

    def normalize_paper_list(items)
      normalize_papers(items)
    end

    def results_as_json(results, query, page: 1, per_page: 10)
      papers_data = results[:papers] || results["papers"] || {}
      items = papers_data.is_a?(Hash) ? papers_data[:items] || papers_data["items"] : papers_data
      total = papers_data.is_a?(Hash) ? (papers_data[:total] || papers_data["total"]).to_i : 0
      total_pages = per_page > 0 ? (total.to_f / per_page).ceil : 1

      {
        query: query.to_s,
        papers: normalize_papers(items),
        authors: normalize_authors(results[:authors] || results["authors"]),
        page:,
        total_papers: total,
        total_pages: [total_pages, 1].max,
      }
    end

    def autocomplete_as_json(results, query)
      {
        query: query.to_s,
        items: normalize_author_suggestions(results[:authors] || results["authors"]) +
          normalize_paper_suggestions(results[:papers] || results["papers"]),
      }
    end

    private

    def normalize_papers(items)
      Array(items).map do |paper|
        external_ids = value(paper, :externalIds) || {}
        doi = value(external_ids, :DOI)

        {
          id: value(paper, :id),
          route_id: route_id(value(paper, :id)),
          type: "paper",
          title: value(paper, :title),
          year: value(paper, :year),
          publication_date: value(paper, :publicationDate, :publication_date),
          venue: value(paper, :venue),
          abstract: value(paper, :abstract),
          citation_count: count_value(paper, :citation_count, :citationCount),
          is_open_access: value(paper, :isOpenAccess, :is_open_access),
          fields_of_study: Array(value(paper, :fieldsOfStudy, :fields_of_study)),
          authors: normalize_authors_with_ids(paper),
          doi:,
          url: value(paper, :url),
          path: "/scholar/paper/#{route_id(value(paper, :id))}",
        }.compact
      end
    end

    def normalize_authors(items)
      Array(items).map do |author|
        {
          id: value(author, :id),
          route_id: route_id(value(author, :id)),
          type: "author",
          name: value(author, :name),
          affiliations: Array(value(author, :affiliations)),
          paper_count: count_value(author, :paper_count, :paperCount),
          citation_count: count_value(author, :citation_count, :citationCount),
          h_index: count_value(author, :h_index, :hIndex),
          path: "/scholar/author/#{route_id(value(author, :id))}",
        }.compact
      end
    end

    def normalize_paper_suggestions(items)
      Array(items).filter_map do |item|
        title = value(item, :title)
        next if title.blank?

        paper_id = value(item, :paperId, :id)
        next if paper_id.blank?

        rid = route_id(paper_id)
        {
          id: paper_id,
          route_id: rid,
          type: "paper",
          label: title,
          path: "/scholar/paper/#{rid}",
        }
      end
    end

    def normalize_author_suggestions(items)
      Array(items).filter_map do |item|
        name = value(item, :name)
        next if name.blank?

        author_id = value(item, :authorId, :id)
        next if author_id.blank?

        rid = route_id(author_id)
        {
          id: author_id,
          route_id: rid,
          type: "author",
          label: name,
          subtext: Array(value(item, :affiliations)).first,
          path: "/scholar/author/#{rid}",
        }.compact
      end
    end

    def normalize_authors_with_ids(paper)
      Array(value(paper, :authors)).filter_map do |author|
        source = author["author"] || author[:author] || author
        name = value(source, :name)
        next if name.blank?

        author_id = value(source, :authorId, :id)
        entry = { name: }
        if author_id.present?
          entry[:path] = "/scholar/author/#{route_id(author_id)}"
        end
        entry
      end
    end
  end
end
