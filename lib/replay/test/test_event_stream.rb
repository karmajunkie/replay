module Replay
  class TestEventStream

    def initialize
      @events = []
    end
    def publish(stream_id, event)
      @events << {stream: stream_id, event: event}
    end

    def published_event?(event)
      @events.detect{|e| e[:event]==event}
    end

    def published?(stream_id, event)
      @events.detect{|e| e == {stream: stream_id, event: event}}
    end
  end
end
