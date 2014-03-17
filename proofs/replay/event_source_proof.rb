require_relative "../proofs_init.rb"

class ReplayTest
  include Replay::EventSource
end

class ReplayTest
  include Replay::EventSource
  events do
    SomeEvent(pid: Integer)
  end

  apply SomeEvent do |event|
    @event_applied = event.pid
  end
end

module ReplayTest::Proof
  def defines_events?
    self.class.const_defined?(:SomeEvent) && self.class.const_get(:SomeEvent).is_a?(Class)
  end
  def adds_convenience_method?
    respond_to? :SomeEvent
  end
  def applies_event?(event)
    apply(event)
    @event_applied == event.pid
  end
end

title "Event source"

proof "Defines events given in the events block" do
  r = ReplayTest.new
  r.prove{ defines_events? }
end

proof "Adds a convenience method for an event constructor to the class" do
  r = ReplayTest.new
  r.prove{ adds_convenience_method? }
end

proof "Applies events" do
  r = ReplayTest.new
  r.prove{ applies_event? ReplayTest::SomeEvent.new(:pid => 123)}
end


