module Replay
  class SubscriptionManager

    def initialize(logger = nil)
      @subscribers = []
      @logger = logger
    end

    def add_subscriber(subscriber)
      if subscriber.respond_to?(:published)
        @subscribers << subscriber 
      else
        raise Replay::InvalidSubscriberError.new(subscriber)
      end
    end

    def notify_subscribers(stream_id, event)
      @subscribers.each do |sub|
        begin
          sub.published(stream_id, event)
        rescue Exception => e
          #hmmmm
          @logger.error "exception in event subscriber #{sub.class.to_s} while handling event stream #{stream_id} #{event.inspect}: #{e.message}\n#{e.backtrace.join("\n")}" if @logger
        end
      end
    end
  end
end
