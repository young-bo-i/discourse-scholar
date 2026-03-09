# frozen_string_literal: true

RSpec.describe DiscourseScholar::PapersController do
  before do
    SiteSetting.discourse_scholar_enabled = true
    SiteSetting.discourse_scholar_api_base_url = "https://open.scholay.com"
    SiteSetting.discourse_scholar_api_proxy_secret = "proxy-secret"
  end

  describe "GET /scholar/paper/:id" do
    it "renders the discourse app shell for html requests" do
      get "/scholar/paper/example-paper"

      expect(response.status).to eq(200)
      expect(response.media_type).to eq("text/html")
    end

    it "returns normalized paper details for json requests" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/get").with(
        headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "X-RapidAPI-Proxy-Secret" => "proxy-secret",
        },
        body: {
          id: "example-paper",
          fields: DiscourseScholar::PAPER_FIELDS.join(","),
        }.to_json,
      ).to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body:
          {
            code: 0,
            message: "success",
            data: {
              id: "stc:example-paper",
              source: "stc",
              title: "Retrieval-Augmented Academic Search",
              abstract: "A survey of academic search systems.",
              year: 2024,
              publication_date: "2024-03-15",
              venue: "Journal of Search",
              doi: "10.1000/example",
              citation_count: 42,
              reference_count: 9,
              is_open_access: true,
              url: "https://example.com/paper",
              pdf_url: "https://example.com/paper.pdf",
              fields_of_study: ["Computer Science", "Information Retrieval"],
              authors: [
                {
                  id: "author-1",
                  name: "Ada Lovelace",
                  affiliations: ["Analytical Engine Institute"],
                },
              ],
            },
          }.to_json,
      )

      get "/scholar/paper/example-paper.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["title"]).to eq("Retrieval-Augmented Academic Search")
      expect(response.parsed_body["citation_count"]).to eq(42)
      expect(response.parsed_body["authors"].first["name"]).to eq("Ada Lovelace")
      expect(response.parsed_body["fields_of_study"]).to eq(
        ["Computer Science", "Information Retrieval"],
      )
    end

    it "returns 404 when the upstream response has no paper data" do
      stub_request(:post, "https://open.scholay.com/v1/stc/papers/get").to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/json",
        },
        body: { code: 0, message: "success", data: nil }.to_json,
      )

      get "/scholar/paper/missing-paper.json"

      expect(response.status).to eq(404)
    end

    it "returns 503 when the proxy secret has not been configured" do
      SiteSetting.discourse_scholar_api_proxy_secret = ""

      get "/scholar/paper/example-paper.json"

      expect(response.status).to eq(503)
      expect(response.parsed_body["errors"]).to include(
        I18n.t("discourse_scholar.errors.missing_proxy_secret"),
      )
    end
  end
end
