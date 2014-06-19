module Replay
  module Subscriptions
    def subscription_manager
      @subscription_manager ||= Replay::SubscriptionManager.new(Replay.logger)
    end

    def subscription_manager=(sm)
      @subscription_manager = sm
    end

    def add_subscriber(subscriber)
      subscription_manager.add_subscriber(subscriber)
    end

    def published(envelope)
      subscription_manager.notify_subscribers(*(envelope.explode))
    end
  end
end
