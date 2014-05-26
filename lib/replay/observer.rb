module Replay
  module Observer

    def self.included(base)
      base.extend(ClassMethods)
      base.instance_variable_set(:@router, Replay::Router::DefaultRouter)
    end

    module ClassMethods
      def router(rtr)
        raise Replay::InvalidRouterError.new("Router does not implement add_observer") unless rtr.respond_to?(:add_observer) 
        @router = rtr
      end

      def observe(event_type, &block)
        raise InvalidRouterError.new("No router defined!") unless @router
        @observer_blocks ||= Hash.new
        @observer_blocks[Replay::Inflector.underscore(event_type.to_s)] = block

        @router.add_observer self, event_type
      end

      def published(stream_id, event)
        blk = @observer_blocks[Replay::Inflector.underscore(event.type)]
        blk.call(stream_id, event, binding) if blk
      end
    end
  end
end
