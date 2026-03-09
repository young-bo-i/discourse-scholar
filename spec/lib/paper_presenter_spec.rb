# frozen_string_literal: true

RSpec.describe DiscourseScholar::PaperPresenter do
  describe "#as_json" do
    it "normalizes mixed field naming styles" do
      payload = {
        "id" => "stc:paper-1",
        "source" => "stc",
        "title" => "Hybrid Academic Detail Pages",
        "abstract" => "A paper about presenting papers.",
        "year" => 2025,
        "publicationDate" => "2025-01-02",
        "citationCount" => 13,
        "references" => [{ "id" => "ref-1" }, { "id" => "ref-2" }],
        "journal" => { "name" => "Designing Search Interfaces" },
        "externalIds" => { "DOI" => "10.1000/hybrid" },
        "url" => "javascript:alert(1)",
        "openAccessPdf" => { "url" => "https://example.com/paper.pdf" },
        "fieldsOfStudy" => [{ "name" => "Computer Science" }, "Human-Computer Interaction"],
        "authors" => [
          {
            "author" => {
              "authorId" => "author-1",
              "name" => "Ada Lovelace",
              "url" => "https://example.com/ada",
            },
            "affiliations" => ["Analytical Engine Institute"],
          },
        ],
      }

      result = described_class.new(payload).as_json

      expect(result[:publication_date]).to eq("2025-01-02")
      expect(result[:route_id]).to eq("paper-1")
      expect(result[:venue]).to eq("Designing Search Interfaces")
      expect(result[:doi]).to eq("10.1000/hybrid")
      expect(result[:doi_url]).to eq("https://doi.org/10.1000/hybrid")
      expect(result[:citation_count]).to eq(13)
      expect(result[:reference_count]).to eq(2)
      expect(result[:url]).to eq(nil)
      expect(result[:pdf_url]).to eq("https://example.com/paper.pdf")
      expect(result[:fields_of_study]).to eq(
        ["Computer Science", "Human-Computer Interaction"],
      )
      expect(result[:authors]).to eq(
        [
          {
            id: "author-1",
            route_id: "author-1",
            name: "Ada Lovelace",
            url: "https://example.com/ada",
            affiliations: ["Analytical Engine Institute"],
            path: "/scholar/author/author-1",
          },
        ],
      )
    end
  end
end
