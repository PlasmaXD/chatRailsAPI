# config/routes.rb

Rails.application.routes.draw do
  resources :chat_rooms do
    resources :messages, only: [:index, :create, :destroy]  # destroy を追加
  end
  resources :users

  # ログイン用のルートを追加
  post '/users/login', to: 'users#login'
end
