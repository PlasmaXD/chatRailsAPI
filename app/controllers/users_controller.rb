class UsersController < ApplicationController
  # Deviseの認証メソッドを使用するために追加
  # before_action :authenticate_user!, only: [:logout]
  def show_current_user
    if current_user
      render json: { user: current_user }, status: :ok
    else
      render json: { error: 'Not logged in' }, status: :unauthorized
    end
  end
  # 新規登録
  def register
    user = User.new(user_params)
    if user.save
      sign_in(user)  # Deviseの sign_in メソッドを使用
      render json: { message: "User created successfully." }, status: :created
    else
      Rails.logger.error(user.errors.full_messages.to_sentence)
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ログイン
  def login
    user = User.find_by(name: params[:user][:name])
    if user && user.valid_password?(params[:user][:password])
      sign_in(user)  # Deviseの sign_in メソッドを使用
      render json: { message: "Login successful.", authentication_token: user.authentication_token }, status: :ok
    else
      render json: { error: "Invalid name or password." }, status: :unauthorized
    end
  end
  # def logout
  #   sign_out(current_user)
  #   render json: { message: "Logged out successfully." }, status: :ok
  # end
  private

  def user_params
    params.require(:user).permit(:name, :password)
  end
end
