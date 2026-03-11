# frozen_string_literal: true

RSpec.describe DiscourseScholar::PaperClient do
  subject(:client) { described_class.new }

  before do
    SiteSetting.discourse_scholar_api_base_url = "https://open.scholay.com"
    SiteSetting.discourse_scholar_api_key = "scholar-api-key"
    DiscourseScholar::BaseClient.reset_connection!
  end

  describe "#fetch" do
    it "returns parsed paper data on success" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/get").with(
        headers: {
          "Authorization" => "Bearer scholar-api-key",
        },
        body: {
          id: "paper-1",
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          message: "success",
          data: {
            id: "stc:paper-1",
            title: "Paper title",
          },
        }.to_json,
      )

      expect(client.fetch("paper-1")).to include("title" => "Paper title")
    end

    it "raises a not found error when the upstream payload reports no paper" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/get").with(
        headers: {
          "Authorization" => "Bearer scholar-api-key",
        },
        body: {
          id: "missing-paper",
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: { code: 0, message: "success", data: nil }.to_json,
      )

      expect { client.fetch("missing-paper") }.to raise_error(
        described_class::ResourceNotFound,
        I18n.t("discourse_scholar.errors.paper_not_found"),
      )
    end

    it "raises an upstream error when the remote service fails" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/get").with(
        headers: {
          "Authorization" => "Bearer scholar-api-key",
        },
        body: {
          id: "paper-1",
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 500,
        headers: {
          "Content-Type" => "application/json",
        },
        body: { success: false, error: { message: "upstream failed" } }.to_json,
      )

      expect { client.fetch("paper-1") }.to raise_error(
        described_class::UpstreamError,
        "upstream failed",
      )
    end

    it "rejects non-OpenScholay base URLs" do
      SiteSetting.discourse_scholar_api_base_url = "https://example.com"

      expect { client.fetch("paper-1") }.to raise_error(
        described_class::MissingConfiguration,
        I18n.t("discourse_scholar.errors.invalid_base_url"),
      )
    end

    it "allows an OpenScholay base URL with a path prefix and mixed-case host" do
      SiteSetting.discourse_scholar_api_base_url = "https://OPEN.SCHOLAY.COM/proxy"
      DiscourseScholar::BaseClient.reset_connection!

      stub_request(:post, "https://open.scholay.com/proxy/v1/stc/papers/get").with(
        headers: {
          "Authorization" => "Bearer scholar-api-key",
        },
        body: {
          id: "paper-1",
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          message: "success",
          data: {
            id: "stc:paper-1",
            title: "Paper title",
          },
        }.to_json,
      )

      expect(client.fetch("paper-1")).to include("title" => "Paper title")
    end

    it "requires an API key" do
      SiteSetting.discourse_scholar_api_key = ""

      expect { client.fetch("paper-1") }.to raise_error(
        described_class::MissingConfiguration,
        I18n.t("discourse_scholar.errors.missing_api_key"),
      )
    end
  end
end
