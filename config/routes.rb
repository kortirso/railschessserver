Rails.application.routes.draw do
    devise_for :users
    resources :games, except: [:edit, :update]
    post 'turn' => 'chess#make_turn', as: 'make_turn'
    get 'surrender/:game/:user' => 'chess#surrender', as: 'surrender'
    root to: 'games#index'
end
