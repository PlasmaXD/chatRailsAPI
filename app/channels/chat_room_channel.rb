class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:chat_room_id]}"
  end

  def unsubscribed
    # クリーンアップ処理
  end
end
