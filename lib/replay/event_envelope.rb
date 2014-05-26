module Replay
  class EventEnvelope
    attr_reader :stream_id, :event, :metadata
    def initialize(stream_id, event, metadata = {})
      @metadata = metadata
      @event = event
      @stream_id = stream_id
    end

    def type
      @event.type
    end

    def method_missing(method, *args)
      return @event.send(method, args) if @event.respond_to?(method)
      super
    end
  end
end
