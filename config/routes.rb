Rails.application.routes.draw do
  root "github_profiles#search_profile"
  
  get "search_profile", to: "github_profiles#search_profile"
  post "fetch_profile", to: "github_profiles#fetch_profile"
  get "github_profiles", to: "github_profiles#index"
end
