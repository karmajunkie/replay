module Replay
  module Repository
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def configuration
        @configuration ||= Configuration.new
      end

      # load will always return an initialized instance of the supplied class (unless it doesn't!). if the given
      # stream has no events (e.g. is not found, new object, etc), load will attempt to call 
      # create on the newly initalized instance of klass
      #
      #options:
      #  :create => true  #if false, do not call create on this instance if no stream is found
      def load(klass, stream_id, options={})
        repository_load(klass, stream_id, options)
      end

      def repository_load(klass, stream_id, options={})
        events = store.event_stream(stream_id)
        if events.empty?
          raise Errors::EventStreamNotFoundError.new("Could not find any events for stream identifier #{stream_id}") if options[:create].nil?
        end

        obj = prepare(klass.new)
        obj.create(stream_id) if options[:create] && events.empty?
        obj.apply(events)

        obj
      end

      #refresh reloads the object from the data store
      #naive implementation is just a reload. Once deltas are in place
      #it can just apply the delta events to the object
      def self.refresh(obj)
        new_obj = load(obj.class, obj.to_key)
        new_obj
      end

      def prepare(obj)
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
