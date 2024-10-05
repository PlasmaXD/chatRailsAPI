Rails.application.routes.draw do
  # Deviseの設定（registrationsをスキップ）
  devise_for :users, skip: [:registrations]

  # ホームページのルート
  get 'home/index'

  # 現在のユーザーを取得するルート
  get '/users/current', to: 'users#show_current_user'

  # チャットルームとメッセージのルート設定（ネストされたリソース）
  resources :chat_rooms do
    resources :messages, only: [:index, :create, :destroy] do
      get :suggest_reply, on: :collection  # 推奨返信の取得エンドポイント
    end
  end

  # ユーザーのCRUDルート
  resources :users

  # ユーザーのログインと登録用ルート
  post '/users/login', to: 'users#login'
  post '/users/register', to: 'users#register'

  # ActionCableのマウント
  mount ActionCable.server => '/cable'
end
