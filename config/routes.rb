Rails.application.routes.draw do
  root "github_profiles#index"
  
  resources :github_profiles, only: [:index, :show]
  get "search_profile", to: "github_profiles#search_profile"
  post "fetch_profile", to: "github_profiles#fetch_profile"
end
