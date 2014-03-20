module Replay
  module Publisher
    def self.included(base)
      base.instance_variable_set :@application_blocks, {}
      base.extend ClassMethods
      base.extend(Replay::Events)
    end
    attr_accessor :publisher

    def initialize()
      @_events ||= []
      super
    end
    def apply(events, raise_unhandled = true)
      return apply([events], raise_unhandled) unless events.is_a?(Array)

      events.each do |event|
        blk = block_for(event.class)
        raise UnhandledEventError.new "event #{event.class.name} is not handled by #{self.class.name}" if (blk.nil? && raise_unhandled)
        self.instance_exec(event, &block_for(event.class))
        @_events << event
      end
      return self
    end

    def block_for(event_type)
      self.class.block_for(event_type)
    end
    protected :block_for

    def publish(event)
      apply(event)
      @publisher.publish(to_key, event) if @publisher
      return self
    end

    def to_key
      raise Replay::UndefinedKeyError.new("No key attribute defined for #{self.class.to_s}") unless self.class.key_attr
      self.send(self.class.key_attr).to_s
    end

    module ClassMethods
      def key(keysym)
        @primary_key_method = keysym
      end

      def key_attr
        @primary_key_method
      end

      def apply(event_type, &block)
        @application_blocks[stringify_class(event_type)] = block
      end

      def block_for(event_type)
        blk = @application_blocks[stringify_class(event_type)]
        return blk
      end

      def stringify_class(klass)
        Replay::Inflector.underscore(klass.to_s.dup)
      end
    end
  end
end
