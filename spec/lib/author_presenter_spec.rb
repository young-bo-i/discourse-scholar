# frozen_string_literal: true

RSpec.describe DiscourseScholar::AuthorPresenter do
  it "normalizes author data and attached papers" do
    author = {
      "id" => "stc:1695689",
      "name" => "Geoffrey Hinton",
      "affiliations" => ["University of Toronto"],
      "paperCount" => 500,
      "citationCount" => 100000,
      "hIndex" => 120,
    }

    papers = {
      "items" => [
        {
          "id" => "stc:paper-1",
          "title" => "Backpropagation",
          "year" => 1986,
          "citationCount" => 999,
        },
      ],
    }

    result = described_class.new(author, papers).as_json

    expect(result[:route_id]).to eq("1695689")
    expect(result[:paper_count]).to eq(500)
    expect(result[:papers].first[:path]).to eq("/scholar/paper/paper-1")
  end
end
