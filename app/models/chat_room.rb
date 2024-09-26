class ChatRoom < ApplicationRecord
  has_many :chat_room_users
  has_many :users, through: :chat_room_users
  has_many :messages

  # enumでの競合を避けるため、キー名と値を明確にする
  enum room_type: { individual_chat: 'individual_chat', group_chat: 'group_chat' }

  # 個別チャットルームの作成
  def self.create_individual_chat(user1, user2)
    chat_room = ChatRoom.create(room_type: 'individual_chat')
    chat_room.users << [user1, user2]
    chat_room
  end

  # グループチャットルームの作成
  def self.create_group_chat(group_name, users)
    chat_room = ChatRoom.create(name: group_name, room_type: 'group_chat')
    chat_room.users << users
    chat_room
  end
end
