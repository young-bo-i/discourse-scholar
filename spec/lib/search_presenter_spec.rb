# frozen_string_literal: true

RSpec.describe DiscourseScholar::SearchPresenter do
  it "builds autocomplete items for papers and authors" do
    result =
      described_class.autocomplete_as_json(
        {
          papers: [{ "id" => "stc:paper-1", "title" => "Attention Is All You Need" }],
          authors: [
            {
              "id" => "stc:author-1",
              "name" => "Ashish Vaswani",
              "affiliations" => ["Google Brain"],
            },
          ],
        },
        "attention",
      )

    expect(result[:items].map { |item| item[:type] }).to eq(%w[paper author])
    expect(result[:items].last[:path]).to eq("/scholar/author/author-1")
  end
end
