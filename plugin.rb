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

module ::DiscourseScholar
  PLUGIN_NAME = "discourse-scholar"
  PAPER_FIELDS =
    %w[
      id
      title
      abstract
      authors
      year
      publication_date
      doi
      citation_count
      reference_count
      venue
      is_open_access
      pdf_url
      url
      fields_of_study
    ].freeze

  AUTHOR_FIELDS = %w[id name affiliations paperCount citationCount hIndex orcid url].freeze
  SEARCH_PAPER_FIELDS = %w[id title authors year citationCount venue].freeze
  SEARCH_AUTHOR_FIELDS = %w[id name affiliations paperCount citationCount hIndex].freeze
  AUTOCOMPLETE_AUTHOR_FIELDS = %w[id name affiliations].freeze
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
