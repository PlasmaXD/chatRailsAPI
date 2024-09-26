class MessagesController < ApplicationController
  before_action :set_chat_room, only: [:index, :create, :suggest_reply]

  # メッセージ一覧取得
  def index
    messages = @chat_room.messages.includes(:user)
    render json: messages.as_json(include: { user: { only: [:id, :name] } })
  end

  # メッセージ送信
  def create
    message = @chat_room.messages.new(message_params.merge(user_id: current_user.id))

    if message.save
      # メッセージのブロードキャスト
      ActionCable.server.broadcast(
        "chat_room_#{@chat_room.id}",
        { message: message.as_json(include: { user: { only: [:id, :name] } }) }
      )

      # 推奨返信の取得
      begin
        suggest_reply(@chat_room.id)
      rescue => e
        Rails.logger.error("推奨返信の取得中にエラーが発生しました: #{e.message}")
      end

      # メッセージ作成のレスポンス
      render json: message.as_json(include: { user: { only: [:id, :name] } }), status: :created
    else
      Rails.logger.error(message.errors.full_messages.to_sentence)
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # 推奨返信取得用のアクションを追加
  def suggest_reply
    suggested_reply = GcpLlmService.new(@chat_room.id).fetch_suggested_reply

    if suggested_reply.present?
      render json: { suggested_reply: suggested_reply }, status: :ok
    else
      render json: { error: "推奨返信の取得に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def set_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
