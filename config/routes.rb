# frozen_string_literal: true

DiscourseScholar::Engine.routes.draw do
  get "/scholar" => "home#show"
  get "/scholar/paper/:id/citations" => "papers#citations", defaults: { format: :json }
  get "/scholar/paper/:id/references" => "papers#references", defaults: { format: :json }
  get "/scholar/paper/:id/related" => "papers#related", defaults: { format: :json }
  get "/scholar/paper/:id" => "papers#show"
  get "/scholar/author/:id" => "authors#show"
  get "/scholar/search" => "search#show"
  get "/scholar/autocomplete" => "search#autocomplete", defaults: { format: :json }
  post "/scholar/translate" => "translate#create", defaults: { format: :json }
end

Discourse::Application.routes.draw do
  mount DiscourseScholar::Engine, at: "/"
end
