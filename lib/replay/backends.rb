require 'singleton'
module Replay
  class Backends
    def self.register(shorthand, klass)
      @backends ||= {}
      @backends[shorthand] = klass
      return klass
    end
    def self.resolve(shorthand)
      @backends[shorthand] || shorthand
    end

    class MemoryStore
      include Singleton
      def initialize
        @store = {}
      end
      def self.published(envelope)
        instance.published(envelope)
      end

      def self.clear
        instance.clear
      end

      def clear
        @store = {}
      end

      def published(envelope)
        @store[envelope.stream_id] ||= []
        @store[envelope.stream_id] << envelope
      end
      
      def event_stream(stream_id)
        @store[stream_id] || []
      end

      def self.event_stream(stream_id)
        instance.event_stream(stream_id)
      end
      def self.[](stream_id)
        instance.event_stream(stream_id)
      end
    end
    register :memory, MemoryStore
  end
end


