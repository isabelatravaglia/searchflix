Rails.application.routes.draw do
  # get 'movies/index'
  devise_for :users
  root to: 'pages#home'

  resources :movies, only: [:index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
