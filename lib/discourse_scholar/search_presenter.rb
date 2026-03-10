# frozen_string_literal: true

module DiscourseScholar
  class SearchPresenter < BasePresenter
    class << self
      def results_as_json(results, query)
        new.results_as_json(results, query)
      end

      def autocomplete_as_json(results, query)
        new.autocomplete_as_json(results, query)
      end

      def papers_as_json(items)
        new.send(:normalize_papers, items)
      end
    end

    def results_as_json(results, query)
      {
        query: query.to_s,
        papers: normalize_papers(results[:papers] || results["papers"]),
        authors: normalize_authors(results[:authors] || results["authors"]),
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
          authors: normalize_authors_for_paper(paper),
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

        {
          id: value(item, :id),
          route_id: route_id(value(item, :id)),
          type: "paper",
          label: title,
          path: "/scholar/paper/#{route_id(value(item, :id))}",
        }
      end
    end

    def normalize_author_suggestions(items)
      Array(items).filter_map do |item|
        name = value(item, :name)
        next if name.blank?

        {
          id: value(item, :id),
          route_id: route_id(value(item, :id)),
          type: "author",
          label: name,
          subtext: Array(value(item, :affiliations)).first,
          path: "/scholar/author/#{route_id(value(item, :id))}",
        }.compact
      end
    end

    def normalize_authors_for_paper(paper)
      Array(value(paper, :authors)).filter_map do |author|
        source = author["author"] || author[:author] || author
        value(source, :name)
      end
    end

    def count_value(object, *keys)
      keys.each do |key|
        raw = value(object, key)
        return raw.to_i if raw.present?
      end

      nil
    end
  end
end
