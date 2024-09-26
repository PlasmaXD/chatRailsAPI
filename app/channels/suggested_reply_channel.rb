# /chatapp/app/channels/suggested_reply_channel.rb

class SuggestedReplyChannel < ApplicationCable::Channel
  def subscribed
    conversation_id = params[:conversation_id]
    stream_from "suggested_reply_#{conversation_id}"
  end

  def unsubscribed
    # 必要に応じてクリーンアップ処理
  end
end
