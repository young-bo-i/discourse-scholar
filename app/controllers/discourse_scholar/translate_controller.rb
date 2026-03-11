# frozen_string_literal: true

module DiscourseScholar
  class TranslateController < BaseController
    TRANSLATE_CACHE_TTL = 24.hours

    MAX_TITLE_LENGTH = 500
    MAX_ABSTRACT_LENGTH = 10_000

    def create
      title = params[:title].to_s.strip.first(MAX_TITLE_LENGTH).presence
      abstract = params[:abstract].to_s.strip.first(MAX_ABSTRACT_LENGTH).presence

      unless title || abstract
        return render_json_error(I18n.t("discourse_scholar.errors.translate_no_content"), status: 422)
      end

      cache_key = "scholar_translate:#{Digest::MD5.hexdigest("#{title}||#{abstract}")}"

      result = cached_json(cache_key, expires_in: TRANSLATE_CACHE_TTL, rate_limit_scope: "translate") do
        TranslateClient.translate(title: title, abstract: abstract)
      end

      render json: result
    rescue TranslateClient::ConfigurationError => e
      render_json_error(e.message, status: 503)
    rescue TranslateClient::TranslationError => e
      render_json_error(e.message, status: 502)
    end
  end
end
