Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :products, only: %i[index show new create destroy]
  root "products#index"
end
