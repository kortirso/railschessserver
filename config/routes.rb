Rails.application.routes.draw do
    devise_for :users
    resources :games, except: [:edit, :update]
    
    namespace :chess do
        post 'turn' => 'turn#index', as: 'make_turn'
        get 'surrender/:game/:user' => 'surrender#index', as: 'surrender'
    end

    root to: 'games#index'
end
