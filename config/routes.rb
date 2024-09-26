# config/routes.rb

Rails.application.routes.draw do
  devise_for :users,skip: [:registrations]

  get 'home/index'
  get '/users/current', to: 'users#show_current_user' # 現在のユーザーを取得するルート

  # ChatRoomsとMessagesのルート設定
  resources :chat_rooms do
    resources :messages, only: [:index, :create, :destroy]  # index, create, destroy アクションに対応
  end

  resources :users

  # ユーザーのログインと登録用ルート
  post '/users/login', to: 'users#login'
  post '/users/register', to: 'users#register'

  # namespace :api do
  #   namespace :v1 do
  #     resources :messages, only: [:create] do
  #       collection do
  #         get :suggest_reply  # 推奨返信の取得
  #       end
  #     end
  #   end
  # end
  # ChatRoomsとMessagesのルート設定
  resources :chat_rooms do
    resources :messages, only: [:index, :create, :destroy] do
      get :suggest_reply, on: :collection  # 推奨返信の取得エンドポイントを追加
    end
  end

  mount ActionCable.server => '/cable'
end
