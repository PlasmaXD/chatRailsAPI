# config/routes.rb

Rails.application.routes.draw do
  # root 'home#index'
  get 'home/index'
  resources :chat_rooms do
    resources :messages, only: [:index, :create, :destroy]  # destroy を追加
  end
  resources :users
  # root 'home#index'
  # root "rails/welcome#index"
  # ログイン用のルートを追加
  post '/users/login', to: 'users#login'
end
