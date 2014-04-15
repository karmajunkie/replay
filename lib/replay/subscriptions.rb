module Replay
  module Subscriptions
    def subscription_manager
      @subscription_manager ||= Replay::SubscriptionManager.new(Replay.logger)
    end

    def add_subscriber(subscriber)
      subscription_manager.add_subscriber(subscriber)
    end

    def published(stream_id, event)
      @subscription_manager.notify_subscribers(stream_id, event)
    end
  end
end
