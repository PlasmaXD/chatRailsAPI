class MessagesController < ApplicationController
  include ActionController::MimeResponds
  before_action :set_default_response_format
  before_action :set_message, only: [:destroy]  # destroyの前にメッセージを取得

  def index
    chat_room = ChatRoom.find(params[:chat_room_id])
    messages = chat_room.messages.includes(:user)
    render json: messages.as_json(include: { user: { only: [:id, :name] } })
  end

  def create
    chat_room = ChatRoom.find(params[:chat_room_id])
    message = chat_room.messages.new(message_params)

    if message.save
      # ブロードキャストの引数を正しく渡す
      ActionCable.server.broadcast(
        "chat_room_#{chat_room.id}",
        {
          message: message.as_json(include: { user: { only: [:id, :name] } })
        }
      )
      render(
        json: message.as_json(include: { user: { only: [:id, :name] } }),
        status: :created
      )
    else
      render(
        json: { errors: message.errors.full_messages },
        status: :unprocessable_entity
      )
    end
  end

  def destroy
    if @message
      @message.destroy
      ActionCable.server.broadcast(
        "chat_room_#{params[:chat_room_id]}",
        { action: 'delete', message_id: @message.id }
      )
      head :no_content
    else
      render json: { error: "Message not found" }, status: :not_found
    end
  end

  private

  def set_default_response_format
    request.format = :json
  end

  # 追加: メッセージを取得するメソッド
  def set_message
    @message = Message.find_by(id: params[:id], chat_room_id: params[:chat_room_id])
  end

  def message_params
    params.require(:message).permit(:content, :user_id)
  end
end
