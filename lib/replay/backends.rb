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
      def self.published(stream_id, event)
        instance.published(stream_id, event)
      end

      def self.clear
        instance.clear
      end

      def clear
        @store = {}
      end

      def published(stream_id, event)
        @store[stream_id] ||= []
        @store[stream_id] << event
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


