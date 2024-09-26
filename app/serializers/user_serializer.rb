# frozen_string_literal: true

# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :authentication_token, :created_at, :updated_at
end

