# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast "chat_room_#{chat_room.id}", render_message
  end

  def render_message
    ApplicationController.renderer.render(partial: 'messages/message', locals: { message: self })
  end
end
