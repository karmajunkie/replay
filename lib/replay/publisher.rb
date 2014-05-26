module Replay
  module Publisher
    def self.included(base)
      base.instance_variable_set :@application_blocks, {}
      base.extend ClassMethods
      base.extend(Replay::Events)
      base.class_exec do
        include Replay::Subscriptions
      end
    end

    def apply(events, raise_unhandled = true)
      return apply([events], raise_unhandled) unless events.is_a?(Array)

      events.each do |event|
        apply_method = apply_method_for(event.class)
        raise UnhandledEventError.new "event #{event.type} is not handled by #{self.class.name}" if (!respond_to?(apply_method) && raise_unhandled)
        self.send(apply_method, event)
      end
      return self
    end

    def apply_method_for(klass)
      self.class.apply_method_for(klass)
    end

    private :apply_method_for

    def publish(event, metadata={})
      return publish([event]) unless event.is_a?(Array)
      event.each do |evt|
        metadata = ({:published_at => Time.now}.merge!(metadata))
        apply(evt)
        subscription_manager.notify_subscribers(to_stream_id, evt, metadata)
      end
      return self
    end

    def to_stream_id
      raise Replay::UndefinedKeyError.new("No key attribute defined for #{self.type}") unless self.key_attr
      self.send(self.key_attr).to_s
    end

    def key_attr
      self.class.key_attr
    end

    module ClassMethods
      def key(keysym)
        @primary_key_method = keysym
      end

      def key_attr
        @primary_key_method
      end

      def apply(event_type, &block)
        method_name = apply_method_for(event_type)
        define_method method_name, block
      end

      def stringify_class(klass)
        Replay::Inflector.underscore(klass.to_s.dup)
      end

      def apply_method_for(klass)
        "handle_#{stringify_class(klass).gsub(".", "_")}"
      end
    end
  end
end
