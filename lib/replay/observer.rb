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

      #gives the observer a chance to take itself down to a null state
      #in the event of a catchup
      #must be overridden in the base class
      def reset!
        raise "reset must be implemented in the observing class"
      end

      def observe(event_type, &block)
        raise InvalidRouterError.new("No router defined!") unless @router
        @observed_events ||= Set.new
        @observed_events.add(event_type)

        @observer_blocks ||= Hash.new
        @observer_blocks[Replay::Inflector.underscore(event_type.to_s)] = block

        @router.add_observer self, event_type
      end

      def observed_events
        @observed_events.dup
      end

      def handle(envelope)
        published(envelope)
      end

      def published(envelope)
        blk = @observer_blocks[Replay::Inflector.underscore(envelope.type)]
        blk.call(envelope, binding) if blk
      end

      private
      def handler_method(event_type)
        "handle_#{Replay::Inflector.underscore(event_type.to_s).gsub(".", "_")}"
      end

    end
  end
end
