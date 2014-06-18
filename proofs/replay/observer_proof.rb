require_relative "../proofs_init.rb"
require 'replay/test'

class ThingEvent
  include Replay::EventDecorator
  attribute :foo, String
end
class ThingObserver
  include Replay::Observer

  def self.foo
    @foo ||= ''
  end
  observe ThingEvent do |stream_id, event|
    @foo ||= 'foo'
    @foo = event.foo
  end
end

module ThingObserver::Proof

end
title "Thing observer"
proof "Thing observer does its thing" do
  ThingObserver.prove do
    ThingObserver.handle('123', ThingEvent.new(:foo => "boo"))
    ThingObserver.foo == "boo"
  end
end

proof "observers have observed events" do
  ThingObserver.prove{ ThingObserver.observed_events.include?(ThingEvent)}
end


