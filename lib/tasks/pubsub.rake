# lib/tasks/pubsub.rake

namespace :pubsub do
  desc 'Start Pub/Sub subscriber'
  task listen: :environment do
    puts "Pub/Sub subscriber started"

    # トピックを取得または作成
    topic = $pubsub.topic 'my-topic'
    if topic.nil?
      puts "Topic 'my-topic' not found. Creating topic..."
      topic = $pubsub.create_topic 'my-topic'
    else
      puts "Found topic: #{topic.name}"
    end

    # サブスクリプションを取得または作成
    subscription = topic.subscription 'my-subscription'
    if subscription.nil?
      puts "Subscription 'my-subscription' not found. Creating subscription..."
      subscription = topic.subscribe 'my-subscription'
    else
      puts "Found subscription: #{subscription.name}"
    end

    # サブスクライバーを開始
    subscriber = subscription.listen do |received_message|
      puts "Received message ID: #{received_message.message_id}"
      puts "Data: #{received_message.data}"
      puts "Attributes: #{received_message.attributes}" unless received_message.attributes.empty?
      received_message.acknowledge!  # メッセージの確認応答
    end

    subscriber.start
    puts "Subscriber is running and waiting for messages..."
    subscriber.wait!  # サブスクライバーがメッセージを待ち続ける
  end
end
