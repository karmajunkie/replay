module Replay
  module EventSource
    def self.included(base)
      base.instance_variable_set :@application_blocks, {}
      base.extend ClassMethods
      base.extend(Replay::Events)
    end

    def apply(event)
      self.instance_exec(event, &block_for(event.class))
    end

    def block_for(event_type)
      self.class.block_for(event_type)
    end
    protected :block_for

    module ClassMethods
      def apply(event_type, &block)
        @application_blocks[stringify_class(event_type)] = block
      end

      def block_for(event_type)
        blk = @application_blocks[stringify_class(event_type)]
        raise "shit" unless blk
        return blk
      end

      def stringify_class(klass)
        Replay::Inflector.underscore(klass.to_s.dup)

      end
    end
  end
end
