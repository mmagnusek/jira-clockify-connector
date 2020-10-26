Rails.application.routes.draw do
  resources :users do
    put :sync, on: :member

    resources :time_entries
  end

  root to: "users#index"
end
