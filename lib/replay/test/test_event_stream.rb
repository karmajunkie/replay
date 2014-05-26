require 'replay/test'
module Replay
  class TestEventStream
    include EventExaminer
    attr_accessor :events

    def initialize
      @events = []
    end
    def published(event_envelope)
      @events << event_envelope
    end

    def published_event?(event)
      @events.detect{|e| e.event==event}
    end

    def published?(stream_id, event)
      @events.detect{|e| e.stream_id == stream_id &&  e.event == event}
    end
  end
end
