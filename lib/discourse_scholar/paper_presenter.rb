# frozen_string_literal: true

module DiscourseScholar
  class PaperPresenter < BasePresenter
    def initialize(raw_paper)
      @raw_paper = raw_paper || {}
    end

    def as_json(*)
      {
        id: value(raw_paper, :id),
        route_id: route_id(value(raw_paper, :id)),
        source: value(raw_paper, :source),
        title: value(raw_paper, :title),
        abstract: value(raw_paper, :abstract),
        year: value(raw_paper, :year),
        publication_date: value(raw_paper, :publication_date, :publicationDate),
        venue: normalized_venue,
        doi: normalized_doi,
        doi_url: normalized_doi_url,
        citation_count: normalized_count(:citation_count, :citationCount),
        reference_count: normalized_reference_count,
        is_open_access: normalized_open_access,
        url: safe_url(value(raw_paper, :url)),
        pdf_url: normalized_pdf_url,
        fields_of_study: normalized_fields_of_study,
        authors: normalized_authors,
        path: "/scholar/paper/#{route_id(value(raw_paper, :id))}",
      }.compact
    end

    private

    attr_reader :raw_paper

    def normalized_venue
      value(raw_paper, :venue) || value(raw_paper["journal"] || {}, :name) ||
        value(raw_paper["publicationVenue"] || {}, :name)
    end

    def normalized_doi
      value(raw_paper, :doi) || value(raw_paper["externalIds"] || {}, :DOI) ||
        value(raw_paper["external_ids"] || {}, :DOI)
    end

    def normalized_doi_url
      doi = normalized_doi
      doi.present? ? safe_url("https://doi.org/#{doi}") : nil
    end

    def normalized_count(*keys)
      keys.each do |key|
        raw = value(raw_paper, key)
        return raw.to_i if raw.present?
      end

      nil
    end

    def normalized_reference_count
      normalized_count(:reference_count, :referenceCount) || raw_paper["references"]&.size
    end

    def normalized_open_access
      open_access = value(raw_paper, :is_open_access, :isOpenAccess)
      return open_access unless open_access.nil?

      raw_paper["openAccessPdf"].present? || raw_paper["open_access_pdf"].present?
    end

    def normalized_pdf_url
      safe_url(
        value(raw_paper, :pdf_url, :pdfUrl) || value(raw_paper["openAccessPdf"] || {}, :url) ||
          value(raw_paper["open_access_pdf"] || {}, :url),
      )
    end

    def normalized_fields_of_study
      Array(value(raw_paper, :fields_of_study, :fieldsOfStudy)).filter_map do |field|
        field.is_a?(Hash) ? field["name"] || field[:name] : field
      end.uniq
    end

    def normalized_authors
      Array(value(raw_paper, :authors)).filter_map do |author|
        normalized_author(author)
      end
    end

    def normalized_author(author)
      return if author.blank?

      source = author["author"] || author[:author] || author
      name = value(source, :name)
      return if name.blank?

      {
        id: value(source, :id, :authorId),
        route_id: route_id(value(source, :id, :authorId)),
        name: name,
        url: safe_url(value(source, :url)),
        orcid: value(source, :orcid),
        affiliations: normalized_affiliations(source, author),
        path: "/scholar/author/#{route_id(value(source, :id, :authorId))}",
      }.compact
    end

    def normalized_affiliations(*sources)
      sources.flat_map do |source|
        Array(value(source, :affiliations)).map do |affiliation|
          affiliation.is_a?(Hash) ? affiliation["name"] || affiliation[:name] : affiliation
        end
      end.compact.uniq
    end
  end
end
