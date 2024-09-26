# frozen_string_literal: true

require 'google/cloud/pubsub'

if Rails.env.development?
  # エミュレーターを使用するための環境変数を設定
  ENV['PUBSUB_EMULATOR_HOST'] ||= 'localhost:8085'

  # エミュレーターに接続するためのクライアントを初期化
  $pubsub = Google::Cloud::Pubsub.new(
    project_id: 'my-project-id',
    credentials: :this_channel_is_insecure
  )
else
  # 本番環境などでは正式なクライアントを初期化
  $pubsub = Google::Cloud::Pubsub.new(
    project_id: 'my-project-id',
    credentials: 'path/to/keyfile.json'
  )
end
