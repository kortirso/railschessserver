Rails.application.routes.draw do
    devise_for :users
    resources :games, except: [:edit, :update]
    root to: 'games#index'
end
