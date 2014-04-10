require_relative "../proofs_init.rb"
require 'replay/test'

class ReplayTest
  include Replay::Publisher
  include Replay::EventExaminer

  key :pkey

  def initialize(pkey = 1)
    @pkey = pkey
  end

  events do
    SomeEvent(pid: Integer)
    UnhandledEvent(pid: Integer)
  end

  apply SomeEvent do |event|
    @event_count ||= 0
    @event_applied = event.pid
    @event_count += 1
  end

  def pkey
    @pkey
  end
end

module ReplayTest::Proof
  def sets_publish_time
    publish SomeEvent(pid: 123)
    events.last.published_at != nil && (Time.now - events.last.published_at) < 20
  end

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

  def applies_events?(events)
    apply(events)
    @event_count == events.count
  end

  def throws_unhandled_event?(raise_it = true)
    begin
      apply(UnhandledEvent(pid: 123), raise_it)
    rescue Replay::UnhandledEventError => e
      true && raise_it
    rescue Exception
      !raise_it || false 
    end
  end

  def can_publish_events?
    event = SomeEvent(pid: 123)
    publish(event)
    events.detect{|e| e==event}
  end

  def subscribers_receive_events
    sub = Class.new do
      def published(stream, event)
        @published = true
      end
      def published?; @published; end
    end.new
    add_subscriber(sub)
    publish(ReplayTest::SomeEvent.new(pid: 123))
    sub.published?
  end
  def subscribes()
    sub = Class.new do
      def published(stream, event)
        @published = true
      end
      def published?; @published; end
    end.new
    add_subscriber(sub)
    has_subscriber?(sub)
  end
end

title "Publisher"

proof "Defines events given in the events block" do
  r = ReplayTest.new
  r.prove{ defines_events? }
end

proof "Adds a convenience method for an event constructor to the class" do
  r = ReplayTest.new
  r.prove{ adds_convenience_method? }
end

proof "Applies events singly" do
  r = ReplayTest.new
  r.prove{ applies_event? ReplayTest::SomeEvent.new(:pid => 123)}
end

proof "Applies events in ordered batches" do
  r = ReplayTest.new
  r.prove do applies_events?([
      ReplayTest::SomeEvent.new(:pid => 123), 
      ReplayTest::SomeEvent.new(:pid => 234), 
      ReplayTest::SomeEvent.new(:pid => 456)
    ])
  end
end

proof "Throws an UnhandledEventError for unhandled events" do
  r = ReplayTest.new
  r.prove{ throws_unhandled_event? }
end

proof "Ignores unhandled events if requested" do
  r = ReplayTest.new
  r.prove{ throws_unhandled_event? false}
end

proof "Can publish events to the indicated stream" do
  r = ReplayTest.new
  r.prove { can_publish_events? }
end

proof "Subscriber can subscribe to events from publisher" do
  r = ReplayTest.new
  r.prove{ subscribes }
end

proof "Subscriber receives published events" do
  r = ReplayTest.new
  r.prove{ subscribers_receive_events }
end

proof "Returns self from apply" do
  r = ReplayTest.new
  r.prove{ apply([]) == self}
end
proof "Returns self from publish" do
  r = ReplayTest.new
  r.prove{ publish([]) == self}
end

proof "sets the publish time on events" do
  r = ReplayTest.new
  r.prove{ sets_publish_time }
end

proof "Can implement initializer with arguments" do
  r = ReplayTest.new(:foo)
  r.prove { pkey == :foo }
end
