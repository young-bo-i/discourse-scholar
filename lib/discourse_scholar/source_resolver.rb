# frozen_string_literal: true

module DiscourseScholar
  module SourceResolver
    SOURCES = %w[stc olx].freeze
    DEFAULT_SOURCE = "stc"

    def self.resolve(id_with_source)
      raw = id_with_source.to_s
      if raw.include?(":")
        source, id = raw.split(":", 2)
        SOURCES.include?(source) ? [source, id] : [DEFAULT_SOURCE, raw]
      else
        [detect_source(raw), raw]
      end
    end

    def self.detect_source(id)
      id.match?(/\A[WA]\d+\z/) ? "olx" : "stc"
    end

    def self.paper_client(source)
      source == "olx" ? OlxPaperClient.new : PaperClient.new
    end

    def self.author_client(source)
      source == "olx" ? OlxAuthorClient.new : AuthorClient.new
    end

    def self.search_client(source)
      source == "olx" ? OlxSearchClient.new : SearchClient.new
    end

    def self.valid_source?(source)
      SOURCES.include?(source.to_s)
    end

    def self.normalize_source(source)
      valid_source?(source) ? source.to_s : DEFAULT_SOURCE
    end
  end
end
