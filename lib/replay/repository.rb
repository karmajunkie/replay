module Replay
  module Repository
    class Configuration
      def initialize
        @default_subscribers =[]
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

      def store
        @store
      end
    end

    def self.included(base)
      base.extend(ClassMethods)

    end

    module ClassMethods
      def configuration
        @configuration ||= Configuration.new
      end

      # load will always return an initialized instance of the supplied class. if the given
      # stream has no events (e.g. is not found, new object, etc), load will attempt to call 
      # create on the newly initalized instance of klass
      #
      #options:
      #  :create => true  #if false, do not call create on this instance if no stream is found
      def load(klass, stream_id, options={})
        #implement an identity map
        #@_identities ||= {}
        #return @_identities[[klass,stream_id]] if @_identities[[klass, stream_id]]
        events = store.event_stream(stream_id)
        if events.empty?
          raise Errors::EventStreamNotFoundError.new("Could not find any events for stream identifier #{stream_id}") if options[:create].nil?
        end

        obj = prepare(klass.new)
        obj.create(stream_id) if options[:create] && events.empty?
        obj.apply(events)

        #@_identities[[klass, stream_id]] = obj
        obj
      end

      #refresh reloads the object from the data store
      #naive implementation is just a reload. Once deltas are in place
      #it can just apply the delta events to the object
      def self.refresh(obj)
        new_obj = load(obj.class, obj.to_key)
        new_obj
      end


      #probably not going to keep the identity map here
      def clear_identity_map
        @_identities = {}
      end

      def prepare(obj)
        obj.add_subscriber(@configuration.store)
        @configuration.subscribers.each do |subscriber|
          obj.add_subscriber(subscriber)
        end
        obj
      end

      def configure 
        @configuration ||= Configuration.new
        yield @configuration
        @configuration
      end

      def store
        @configuration.store
      end

    end
  end
end
