module Replay
  class SubscriptionManager

    def initialize
      @subscribers = []
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

        end
      end
    end
  end
end
