# app/controllers/users_controller.rb

class UsersController < ApplicationController
  # 他のアクション（index, show, createなど）が既にある場合は、そのまま残します。

  # ログインアクションの追加
  def login
    user = User.find_by(name: params[:user][:name])

    if user
      # ユーザーが存在する場合、ユーザー情報を返す
      render json: user, status: :ok
    else
      # ユーザーが存在しない場合、新規作成する
      user = User.new(name: params[:user][:name])
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end


  # 他のプライベートメソッドや強いパラメーターの設定があれば、ここに記述します。
end
