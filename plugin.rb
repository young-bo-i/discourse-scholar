# frozen_string_literal: true

# name: discourse-scholar
# about: Adds public scholar pages for papers, authors, and search backed by OpenScholay.
# version: 0.0.1
# authors: Young P
# url: https://github.com/discourse/discourse
# required_version: 2.7.0

enabled_site_setting :discourse_scholar_enabled

register_asset "stylesheets/common/discourse-scholar.scss"
register_asset "stylesheets/mobile/discourse-scholar.scss", :mobile

register_svg_icon "comments"
register_svg_icon "magnifying-glass"
register_svg_icon "users"
register_svg_icon "file-pdf"
register_svg_icon "arrow-up-right-from-square"
register_svg_icon "lock-open"
register_svg_icon "user"
register_svg_icon "chevron-left"
register_svg_icon "chevron-right"
register_svg_icon "quote-left"
register_svg_icon "copy"
register_svg_icon "xmark"
register_svg_icon "file-lines"
register_svg_icon "language"
register_svg_icon "spinner"
register_svg_icon "book-open-reader"
register_svg_icon "globe"
register_svg_icon "lightbulb"

module ::DiscourseScholar
  PLUGIN_NAME = "discourse-scholar"
  PAPER_FIELDS =
    %w[
      title
      abstract
      authors
      year
      publicationDate
      doi
      citationCount
      referenceCount
      venue
      isOpenAccess
      openAccessPdf
      url
      fieldsOfStudy
      externalIds
    ].freeze

  AUTHOR_FIELDS = %w[name affiliations paperCount citationCount hIndex orcid url].freeze
  SEARCH_PAPER_FIELDS = %w[title authors year publicationDate citationCount venue abstract fieldsOfStudy isOpenAccess externalIds url].freeze
  SEARCH_AUTHOR_FIELDS = %w[name affiliations paperCount citationCount hIndex].freeze
  AUTOCOMPLETE_AUTHOR_FIELDS = %w[name affiliations].freeze
  RELATED_PAPER_FIELDS = %w[title authors year citationCount venue].freeze
end

require_relative "lib/discourse_scholar/engine"

after_initialize do
  require_relative "lib/discourse_scholar/base_client"
  require_relative "lib/discourse_scholar/base_presenter"
  require_relative "lib/discourse_scholar/paper_client"
  require_relative "lib/discourse_scholar/author_client"
  require_relative "lib/discourse_scholar/search_client"
  require_relative "lib/discourse_scholar/olx_paper_client"
  require_relative "lib/discourse_scholar/olx_author_client"
  require_relative "lib/discourse_scholar/olx_search_client"
  require_relative "lib/discourse_scholar/source_resolver"
  require_relative "lib/discourse_scholar/paper_presenter"
  require_relative "lib/discourse_scholar/author_presenter"
  require_relative "lib/discourse_scholar/search_presenter"
  require_relative "lib/discourse_scholar/translate_client"
end
