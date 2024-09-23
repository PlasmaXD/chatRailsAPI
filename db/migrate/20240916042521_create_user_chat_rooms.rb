class CreateUserChatRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :user_chat_rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
