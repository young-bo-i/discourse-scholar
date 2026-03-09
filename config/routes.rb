# frozen_string_literal: true

DiscourseScholar::Engine.routes.draw do
  get "/scholar/paper/:id" => "papers#show"
  get "/scholar/author/:id" => "authors#show"
  get "/scholar/search" => "search#show"
  get "/scholar/autocomplete" => "search#autocomplete", defaults: { format: :json }
end

Discourse::Application.routes.draw do
  mount DiscourseScholar::Engine, at: "/"
end
