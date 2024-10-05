class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    chat_room = ChatRoom.find(params[:room_id])
    if chat_room.users.include?(current_user)
      stream_for chat_room
    else
      reject
    end
  end
  def unsubscribed
    # クリーンアップ処理
  end
end
