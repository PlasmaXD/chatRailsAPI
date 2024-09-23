class ChatRoomsController < ApplicationController
  def index
    chat_rooms = ChatRoom.all
    render json: chat_rooms
  end

  def show
    chat_room = ChatRoom.find(params[:id])
    render json: chat_room
  end

  def create
    chat_room = ChatRoom.new(chat_room_params)
    if chat_room.save
      # 新しいチャットルームを作成したことをブロードキャスト
      ActionCable.server.broadcast(
        'chat_rooms_channel',
        { action: 'create', chat_room: chat_room }
      )
      render json: chat_room, status: :created
    else
      # エラーが発生した場合、エラーメッセージを返す
      render json: { errors: chat_room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def chat_room_params
    params.require(:chat_room).permit(:name)
  end
end
