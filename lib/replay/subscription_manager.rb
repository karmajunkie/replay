module Replay
  class SubscriptionManager
    def initialize(logger = nil, session_metadata = {})
      @subscribers = []
      @logger = logger
      @session_metadata = session_metadata
    end

    def add_subscriber(subscriber)
      if subscriber.respond_to?(:published)
        @subscribers << subscriber
      else
        raise Replay::InvalidSubscriberError.new(subscriber)
      end
    end

    def notify_subscribers(stream_id, event, metadata = {})
      @subscribers.each do |sub|
        begin
          meta = metadata.merge(@session_metadata || {}) 
          sub.published(EventEnvelope.new(stream_id, event, meta))
          #sub.published(stream_id, event, metadata)
        rescue Exception => e
          #hmmmm
          if @logger
            @logger.error "exception in event subscriber #{sub.class.to_s} while handling event stream #{stream_id} #{event.inspect}: #{e.message}\n#{e.backtrace.join("\n")}" 
          else
            raise e
          end
        end
      end
    end
  end
end
