Rails.application.routes.draw do
    devise_for :users
    
    resources :games, except: [:edit, :update, :new]
    resources :challenges, only: [:create, :destroy]
    namespace :chess do
        post 'turn' => 'turn#index', as: 'make_turn'
        get 'surrender/:id' => 'surrender#index', as: 'surrender'
    end

    root to: 'welcome#index'
    match "*path", to: "application#catch_404", via: :all
end
