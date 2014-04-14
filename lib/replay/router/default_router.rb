module Replay
  module Router
    class DefaultRouter
      include Singleton

      def initialize
        @subscription_manager = Replay::SubscriptionManager.new
      end

      def add_observer(observer, *events)
        @subscription_manager.add_subscriber(observer)
      end

      def published(stream_id, event)
        @subscription_manager.notify_subscribers(stream_id, event)
      end
    end
  end
end

Replay::Backends.register(:replay_router, Replay::Router::DefaultRouter)
