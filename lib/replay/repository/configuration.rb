module Replay
  module Repository
    class Configuration
      attr_accessor :logger
      attr_writer :reject_load_on_empty_stream
      def initialize(logger = nil)
        @default_subscribers =[]
        @logger = logger
      end

      def self.default
        self.new(Replay.logger)
      end

      def add_default_subscriber(subscriber)
        subscriber = Replay::Backends.resolve(subscriber) if subscriber.is_a?(String) || subscriber.is_a?(Symbol)
        @default_subscribers << subscriber
      end

      def subscribers
        @default_subscribers
      end

      def store=(store)
        store = Replay::Backends.resolve(store)
        raise Replay::InvalidStorageError.new(store) unless store.respond_to?(:event_stream)
        raise Replay::InvalidSubscriberError.new(store) unless store.respond_to?(:published)
        @store = store
        add_default_subscriber(@store)
      end

      def reject_load_on_empty_stream?
        @reject_load_on_empty_stream ||= true
        @reject_load_on_empty_stream
      end

      def store
        @store
      end
    end
  end
end
