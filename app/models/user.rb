class User < ApplicationRecord
  # Deviseのモジュールを含めます。:validatableを除外します。
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         authentication_keys: [:name]  # :name を認証キーとして設定

  has_many :messages, dependent: :destroy, inverse_of: :user
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users

  # カスタムバリデーションを追加
  validates :name, presence: true, uniqueness: true

  # emailを必須にしないための設定
  def email_required?
    false
  end

  def email_changed?
    false
  end

  # 認証トークンの自動生成
  before_create :generate_authentication_token

  private

  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.hex(20)
      break unless User.exists?(authentication_token: authentication_token)
    end
  end
end
