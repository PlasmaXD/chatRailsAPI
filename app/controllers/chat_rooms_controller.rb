class ChatRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat_room, only: [:show, :destroy]

  # GET /chat_rooms
  def index
    @chat_rooms = current_user.chat_rooms.includes(:users)
    render json: @chat_rooms.map { |room|
      {
        id: room.id,
        name: room.name,
        users: room.users.map { |user| { id: user.id, name: user.name } }
      }
    }, status: :ok
  end

  def show
    @chat_room = ChatRoom.find(params[:id])
    # チャットルームのユーザーが現在のユーザーを含んでいるか確認
    unless @chat_room.users.include?(current_user)
      render json: { error: 'アクセスが拒否されました。' }, status: :forbidden
      return
    end

    render json: {
      name: @chat_room.name,
      users: @chat_room.users.map { |user| { id: user.id, name: user.name } }
    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'チャットルームが見つかりません。' }, status: :not_found
  end


  def create
    chat_room = ChatRoom.new(chat_room_params.except(:users))
    if chat_room.save
      # ユーザーを関連付ける
      if params[:chat_room][:users]
        user_ids = params[:chat_room][:users].map(&:to_i) # 確実に整数に変換
        users = User.where(id: user_ids) # whereを使用
        if users.size != user_ids.size
          chat_room.destroy
          render json: { error: '一部のユーザーIDが存在しません。' }, status: :unprocessable_entity
          return
        end
        chat_room.users << users if users.present?
      end
      # 現在のユーザーをチャットルームに追加（重複を避ける）
      chat_room.users << current_user unless chat_room.users.include?(current_user)

      # ブロードキャスト（必要に応じて）
      ActionCable.server.broadcast(
        'chat_rooms_channel',
        { action: 'create', chat_room: chat_room }
      )

      render json: { name: chat_room.name, users: chat_room.users.map { |user| { id: user.id, name: user.name } } }, status: :created
    else
      render json: { errors: chat_room.errors.full_messages }, status: :unprocessable_entity
    end
  end
  # def destroy
  #   # チャットルームの所有者または特定の権限を持つユーザーのみが削除できるようにする場合は、ここで確認します。
  #   # unless @chat_room.owner == current_user
  #   #   render json: { error: '権限がありません。' }, status: :forbidden
  #   #   return
  #   # end
  #
  #   @chat_room.destroy
  #   render json: { message: 'チャットルームが削除されました。' }, status: :ok
  # rescue ActiveRecord::RecordNotFound
  #   render json: { error: 'チャットルームが見つかりません。' }, status: :not_found
  # end

  # DELETE /chat_rooms/:id
  def destroy
    if @chat_room.nil?
      render json: { error: 'チャットルームが見つかりません。' }, status: :not_found
      return
    end

    unless @chat_room.users.include?(current_user)
      render json: { error: 'アクセスが拒否されました。' }, status: :forbidden
      return
    end

    if @chat_room.destroy
      render json: { message: 'チャットルームが削除されました。' }, status: :ok
    else
      Rails.logger.error "チャットルーム削除エラー: #{@chat_room.errors.full_messages.join(', ')}"
      render json: { error: 'チャットルームの削除に失敗しました。' }, status: :internal_server_error
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    Rails.logger.error "チャットルーム削除エラー: #{e.message}"
    render json: { error: 'チャットルームの削除中にエラーが発生しました。' }, status: :internal_server_error
  end

  private
  def set_chat_room
    @chat_room = ChatRoom.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'チャットルームが見つかりません。' }, status: :not_found
    return  # 処理を中断
  end

  def chat_room_params
    params.require(:chat_room).permit(:name, :room_type, users: [])
  end

end
