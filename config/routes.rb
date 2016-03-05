Rails.application.routes.draw do
    devise_for :users
    
    resources :games, except: [:edit, :update]
    namespace :chess do
        post 'turn' => 'turn#index', as: 'make_turn'
        get 'surrender/:id' => 'surrender#index', as: 'surrender'
    end

    root to: 'welcome#index'
end
