module Replay
  module Observer

    def self.included(base)
      class << base
        def observe(event_type, &block)
          @observer_blocks ||= Hash.new
          @observer_blocks[Replay::Inflector.underscore(event_type.to_s)] = block
        end

        def published(stream_id, event)
          blk = @observer_blocks[Replay::Inflector.underscore(event.class.to_s)]
          blk.call(stream_id, event, binding) if blk
        end
      end
    end
  end
end
