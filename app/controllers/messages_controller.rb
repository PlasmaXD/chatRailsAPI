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
  # def suggest_reply
  #   suggested_reply = GcpLlmService.new(@chat_room.id).fetch_suggested_reply
  #
  #   if suggested_reply.present?
  #     render json: { suggested_reply: suggested_reply }, status: :ok
  #   else
  #     render json: { error: "推奨返信の取得に失敗しました" }, status: :unprocessable_entity
  #   end
  # end
  # 推奨返信取得用のアクションを修正
  def suggest_reply
    limit = params[:limit].to_i || 1 # limitパラメータを取得し、デフォルトは1
    suggested_reply = GcpLlmService.new(@chat_room.id, limit).fetch_suggested_reply

    if suggested_reply.present?
      render json: { suggested_reply: suggested_reply }, status: :ok
    else
      render json: { error: "推奨返信の取得に失敗しました" }, status: :unprocessable_entity
    end
  end




  # メッセージ削除
  def destroy
    set_message
    if @message.nil?
      Rails.logger.error("Message with id #{params[:id]} not found in chat_room_id #{params[:chat_room_id]}")
      render json: { error: "Message not found" }, status: :not_found
      return
    else
      Rails.logger.info("Message found: #{@message.inspect}")
    end

    if @message.destroy
      ActionCable.server.broadcast(
        "chat_room_#{params[:chat_room_id]}",
        { action: 'delete', message_id: @message.id }
      )
      head :no_content
    else
      render json: { error: "Failed to delete message" }, status: :unprocessable_entity
    end
  end


  private

  def set_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def set_message
    @message = Message.find_by(id: params[:id], chat_room_id: params[:chat_room_id])
    if @message.nil?
      Rails.logger.error("Message with id #{params[:id]} not found in chat_room_id #{params[:chat_room_id]}")
    end
  end

  # 指定された個数分のメッセージを取得
  def fetch_recent_messages(limit)
    Message.where(chat_room_id: @chat_room.id)
           .order(created_at: :desc)
           .limit(limit)
           .pluck(:content)
           .reverse
           .join("\n")
  end

  # すべてのメッセージ履歴を取得
  def fetch_chat_history
    Message.where(chat_room_id: @chat_room.id)
           .order(:created_at)
           .pluck(:content)
           .join("\n")
  end

end
