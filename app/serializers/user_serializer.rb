# frozen_string_literal: true

# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name
  # 必要に応じて他の属性も追加
end
