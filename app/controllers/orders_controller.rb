# app/controllers/orders_controller.rb

class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    if @order.save
      topic = $pubsub.topic 'orders'
      topic.publish "Order #{@order.id} created"
      redirect_to @order
    else
      render :new
    end
  end
end
