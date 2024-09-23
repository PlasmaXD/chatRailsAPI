class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :chat_room_id, :created_at, :updated_at
  belongs_to :user, serializer: UserSerializer
end
