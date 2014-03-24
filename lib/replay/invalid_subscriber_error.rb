module Replay
  class InvalidSubscriberError < Replay::ReplayError 
    def initialize(*args)
      super( "Subscriber does not implement #published(stream, event)", *args)
    end
  end
end
