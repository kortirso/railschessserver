Rails.application.routes.draw do
    apipie
    use_doorkeeper
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    devise_for :users, controllers: { sessions: 'sessions', registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks' }

    localized do
        resources :games, except: [:edit, :update, :new]
        resources :about, only: :index
        namespace :chess do
            post 'turn' => 'turn#index', as: 'make_turn'
            resources :draw, only: :create
            resources :surrender, only: :show
        end
    end
    resources :challenges, only: [:create, :destroy]
    namespace :ai do
        get 'start' => 'start#index', as: 'start'
    end
    namespace :api do
        namespace :v1 do
            resource :profiles do
                get :me, on: :collection
                get :all, on: :collection
            end
            resources :challenges, only: [:index, :create, :destroy]
            resources :games, only: [:index, :show, :create]
            resources :turns, only: :create
            resources :draws, only: :create
            resources :surrender, only: :show
        end
    end
    get 'locale/:name' => 'application#locale', as: 'change_locale'

    root to: 'welcome#index'
    match "*path", to: "application#catch_404", via: :all
end
