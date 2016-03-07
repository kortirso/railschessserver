Rails.application.routes.draw do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
    
    resources :games, except: [:edit, :update, :new]
    resources :challenges, only: [:create, :destroy]
    namespace :chess do
        post 'turn' => 'turn#index', as: 'make_turn'
        get 'surrender/:id' => 'surrender#index', as: 'surrender'
    end
    namespace :ai do
        get 'start' => 'start#index', as: 'start'
    end

    root to: 'welcome#index'
    match "*path", to: "application#catch_404", via: :all
end
