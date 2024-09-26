# app/models/order.rb

class Order < ApplicationRecord
  after_create :publish_order_created

  private

  def publish_order_created
    topic = $pubsub.topic 'orders'
    topic.publish "Order #{id} created"
  end
end
