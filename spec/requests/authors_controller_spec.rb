# frozen_string_literal: true

RSpec.describe DiscourseScholar::AuthorsController do
  before do
    SiteSetting.discourse_scholar_enabled = true
    SiteSetting.discourse_scholar_api_base_url = "https://open.scholay.com"
    SiteSetting.discourse_scholar_api_proxy_secret = "proxy-secret"
  end

  describe "GET /scholar/author/:id" do
    it "renders the discourse app shell for html requests" do
      get "/scholar/author/1695689"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("text/html")
    end

    it "returns normalized author details for json requests" do
      stub_request(:post, "https://open.scholay.com/v1/stc/authors/get").with(
        body: {
          id: "1695689",
          fields: DiscourseScholar::AUTHOR_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: {
          code: 0,
          data: {
            id: "stc:1695689",
            name: "Geoffrey Hinton",
            affiliations: ["University of Toronto"],
            paperCount: 500,
            citationCount: 100000,
            hIndex: 120,
          },
        }.to_json,
      )

      stub_request(:post, "https://open.scholay.com/v1/stc/authors/papers").with(
        body: {
          author_id: "1695689",
          limit: 12,
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
                title: "Backpropagation",
                year: 1986,
                citationCount: 999,
              },
            ],
          },
        }.to_json,
      )

      get "/scholar/author/1695689.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["name"]).to eq("Geoffrey Hinton")
      expect(response.parsed_body["paper_count"]).to eq(500)
      expect(response.parsed_body["papers"].first["title"]).to eq("Backpropagation")
    end

    it "returns 404 when the author is missing" do
      stub_request(:post, "https://open.scholay.com/v1/stc/authors/get").to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: { code: 0, data: nil }.to_json,
      )

      get "/scholar/author/missing-author.json"

      expect(response.status).to eq(404)
    end
  end
end
