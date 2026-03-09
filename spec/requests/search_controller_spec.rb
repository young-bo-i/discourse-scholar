# frozen_string_literal: true

RSpec.describe DiscourseScholar::SearchController do
  before do
    SiteSetting.discourse_scholar_enabled = true
    SiteSetting.discourse_scholar_api_base_url = "https://open.scholay.com"
    SiteSetting.discourse_scholar_api_proxy_secret = "proxy-secret"
  end

  describe "GET /scholar/search" do
    it "returns combined paper and author search results" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/search").with(
        body: {
          query: "attention",
          limit: 8,
          offset: 0,
          fields: DiscourseScholar::SEARCH_PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          data: {
            items: [
              {
                id: "stc:paper-1",
                title: "Attention Is All You Need",
                year: 2017,
                authors: [{ name: "Ashish Vaswani" }],
              },
            ],
          },
        }.to_json,
      )

      stub_request(:post, "https://open.scholay.com/v1/stc/authors/search").with(
        body: {
          query: "attention",
          limit: 5,
          offset: 0,
          fields: DiscourseScholar::AUTOCOMPLETE_AUTHOR_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          data: {
            items: [
              {
                id: "stc:author-1",
                name: "Ashish Vaswani",
                affiliations: ["Google Brain"],
                paperCount: 50,
              },
            ],
          },
        }.to_json,
      )

      get "/scholar/search.json", params: { q: "attention" }

      expect(response.status).to eq(200)
      expect(response.parsed_body["papers"].first["title"]).to eq("Attention Is All You Need")
      expect(response.parsed_body["authors"].first["name"]).to eq("Ashish Vaswani")
    end
  end

  describe "GET /scholar/autocomplete" do
    it "returns merged autocomplete items" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/autocomplete").with(
        body: {
          query: "attention",
          limit: 5,
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          data: [{ id: "stc:paper-1", title: "Attention Is All You Need" }],
        }.to_json,
      )

      stub_request(:post, "https://open.scholay.com/v1/stc/authors/search").with(
        body: {
          query: "attention",
          limit: 5,
          offset: 0,
          fields: DiscourseScholar::SEARCH_AUTHOR_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          data: {
            items: [{ id: "stc:author-1", name: "Ashish Vaswani", affiliations: ["Google Brain"] }],
          },
        }.to_json,
      )

      get "/scholar/autocomplete.json", params: { q: "attention" }

      expect(response.status).to eq(200)
      expect(response.parsed_body["items"].map { |item| item["type"] }).to include("paper", "author")
    end

    it "returns 503 when the proxy secret is missing" do
      SiteSetting.discourse_scholar_api_proxy_secret = ""

      get "/scholar/autocomplete.json", params: { q: "attention" }

      expect(response.status).to eq(503)
    end
  end
end
