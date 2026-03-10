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

register_svg_icon "graduation-cap"
register_svg_icon "comments"
register_svg_icon "magnifying-glass"
register_svg_icon "users"
register_svg_icon "file-pdf"
register_svg_icon "arrow-up-right-from-square"
register_svg_icon "lock-open"

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
  SEARCH_PAPER_FIELDS = %w[title authors year citationCount venue].freeze
  SEARCH_AUTHOR_FIELDS = %w[name affiliations paperCount citationCount hIndex].freeze
  AUTOCOMPLETE_AUTHOR_FIELDS = %w[name affiliations].freeze
end

require_relative "lib/discourse_scholar/engine"

after_initialize do
  require_relative "lib/discourse_scholar/base_client"
  require_relative "lib/discourse_scholar/base_presenter"
  require_relative "lib/discourse_scholar/paper_client"
  require_relative "lib/discourse_scholar/author_client"
  require_relative "lib/discourse_scholar/search_client"
  require_relative "lib/discourse_scholar/paper_presenter"
  require_relative "lib/discourse_scholar/author_presenter"
  require_relative "lib/discourse_scholar/search_presenter"
end
