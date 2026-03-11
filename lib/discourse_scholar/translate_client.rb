# frozen_string_literal: true

require "json"

module DiscourseScholar
  class TranslateClient
    OPEN_TIMEOUT_SECONDS = 10
    READ_TIMEOUT_SECONDS = 30

    SYSTEM_PROMPT = <<~PROMPT
      You are a professional academic translator. Translate the given academic paper title and abstract from English to Chinese.
      Return ONLY a JSON object with exactly these keys: "translated_title" and "translated_abstract".
      Keep academic terminology accurate. Do not add any explanation or extra text outside the JSON.
    PROMPT

    class Error < StandardError; end
    class ConfigurationError < Error; end
    class TranslationError < Error; end

    def self.translate(title:, abstract:)
      validate_config!

      user_content = build_user_content(title, abstract)
      body = {
        model: SiteSetting.discourse_scholar_llm_model,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: user_content },
        ],
        temperature: 0.3,
      }

      response = connection.post("/v1/chat/completions") do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer #{SiteSetting.discourse_scholar_llm_api_key}"
        req.body = body.to_json
      end

      parse_response(response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise TranslationError, "#{I18n.t("discourse_scholar.errors.translation_unavailable")} (#{e.class.name})"
    end

    def self.validate_config!
      if SiteSetting.discourse_scholar_llm_endpoint.blank? ||
           SiteSetting.discourse_scholar_llm_api_key.blank? ||
           SiteSetting.discourse_scholar_llm_model.blank?
        raise ConfigurationError, I18n.t("discourse_scholar.errors.missing_llm_config")
      end
    end

    def self.connection
      @connection = nil if @cached_endpoint != SiteSetting.discourse_scholar_llm_endpoint
      @connection ||=
        begin
          @cached_endpoint = SiteSetting.discourse_scholar_llm_endpoint
          Faraday.new(
            url: @cached_endpoint,
            request: {
              open_timeout: OPEN_TIMEOUT_SECONDS,
              timeout: READ_TIMEOUT_SECONDS,
            },
          )
        end
    end

    def self.reset_connection!
      @connection = nil
      @cached_endpoint = nil
    end

    def self.build_user_content(title, abstract)
      parts = []
      parts << "Title: #{title}" if title.present?
      parts << "Abstract: #{abstract}" if abstract.present?
      parts.join("\n\n")
    end
    private_class_method :build_user_content

    def self.parse_response(response)
      unless response.status == 200
        raise TranslationError, I18n.t("discourse_scholar.errors.translation_failed")
      end

      data = JSON.parse(response.body)
      content = data.dig("choices", 0, "message", "content")
      raise TranslationError, I18n.t("discourse_scholar.errors.translation_failed") if content.blank?

      result = extract_json_object(content)
      {
        translated_title: result["translated_title"],
        translated_abstract: result["translated_abstract"],
      }
    rescue JSON::ParserError
      raise TranslationError, I18n.t("discourse_scholar.errors.translation_failed")
    end
    private_class_method :parse_response

    def self.extract_json_object(text)
      start_idx = text.index("{")
      raise TranslationError, I18n.t("discourse_scholar.errors.translation_failed") unless start_idx

      depth = 0
      (start_idx...text.length).each do |i|
        depth += 1 if text[i] == "{"
        depth -= 1 if text[i] == "}"
        return JSON.parse(text[start_idx..i]) if depth == 0
      end

      raise TranslationError, I18n.t("discourse_scholar.errors.translation_failed")
    end
    private_class_method :extract_json_object
  end
end
