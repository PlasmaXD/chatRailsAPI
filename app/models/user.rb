class User < ApplicationRecord
  has_many :user_chat_rooms
  has_many :chat_rooms, through: :user_chat_rooms
  has_many :messages
end
