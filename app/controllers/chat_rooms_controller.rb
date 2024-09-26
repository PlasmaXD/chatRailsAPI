class ChatRoomsController < ApplicationController
  before_action :authenticate_user!
  def index
    chat_rooms = ChatRoom.all
    render json: chat_rooms
  end

  def show
    chat_room = ChatRoom.find(params[:id])
    render json: chat_room
  end

  def create
    chat_room = ChatRoom.new(chat_room_params.except(:users))
    if chat_room.save
      # ユーザーを関連付ける
      if params[:chat_room][:users]
        user_ids = params[:chat_room][:users]
        users = User.where(id: user_ids) # whereを使用
        chat_room.users << users if users.present?
      end

      # ブロードキャスト（必要に応じて）
      ActionCable.server.broadcast(
        'chat_rooms_channel',
        { action: 'create', chat_room: chat_room }
      )

      render json: chat_room, status: :created
    else
      render json: { errors: chat_room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def chat_room_params
    params.require(:chat_room).permit(:name, :room_type)
  end
end
