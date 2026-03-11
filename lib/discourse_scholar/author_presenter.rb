# frozen_string_literal: true

module DiscourseScholar
  class AuthorPresenter < BasePresenter
    def initialize(raw_author, raw_papers = {})
      @raw_author = raw_author || {}
      @raw_papers = raw_papers || {}
    end

    def as_json(*)
      {
        id: value(raw_author, :id),
        route_id: route_id(value(raw_author, :id)),
        source: value(raw_author, :source),
        name: value(raw_author, :name),
        affiliations: Array(value(raw_author, :affiliations)),
        paper_count: count_value(raw_author, :paper_count, :paperCount),
        citation_count: count_value(raw_author, :citation_count, :citationCount),
        h_index: count_value(raw_author, :h_index, :hIndex),
        orcid: value(raw_author, :orcid),
        url: safe_url(value(raw_author, :url)),
        path: "/scholar/author/#{source_path_id(raw_author)}",
        papers: normalized_papers,
      }.compact
    end

    private

    attr_reader :raw_author, :raw_papers

    def normalized_papers
      items = raw_papers["items"] || raw_papers[:items] || raw_papers["data"] || []

      Array(items).filter_map do |paper|
        title = value(paper, :title)
        next if title.blank?

        {
          id: value(paper, :id),
          route_id: route_id(value(paper, :id)),
          title: title,
          year: value(paper, :year),
          venue: value(paper, :venue),
          citation_count: count_value(paper, :citation_count, :citationCount),
          path: "/scholar/paper/#{source_path_id(paper)}",
        }.compact
      end
    end
  end
end
