require 'replay/test/test_event_stream'

module Replay::EventExaminer
  def events
    @_events
  end
  def published?(event)
    @_events.detect{|e| event.is_a?(Class) ? e.class == event : e == event}
  end
end
