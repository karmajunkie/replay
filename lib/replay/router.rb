module Replay
  module Router
    def self.included(base)
      base.class_exec do
        include Replay::Subscriptions
        extend ClassMethods if base.include?(Singleton)
      end
    end

    def add_observer(observer, *events)
      add_subscriber observer
    end

    module ClassMethods
      def add_observer(observer, *events)
        instance.add_subscriber(observer)
      end

      def published(envelope)
        instance.published( envelope)
      end
    end
  end
end
