require './test/spec_helper'

describe Replay do
  class ReplayTestClass
    include Replay::Domain

    attr_accessor :bar_value
    attr_accessor :id

    def initialize
      @id = 1
    end

    def foo(arg = "bar")
      signal_event :foo_happened, arg
    end

    def bad_foo
      signal_event :no_foo_lovey
    end

    apply :foo_happened do |what|
      self.bar_value = what
    end
  end

  before do
    @something = ReplayTestClass.new
  end

  describe "behavior with signalling" do
    it "raises an error for unknown events" do
      lambda{@something.bad_foo}.must_raise UnknownEventError
    end

    it "sends the event to the EventStore" do
      Replay::EventStore.expects(:handle_event).with(:foo_happened, 1, 'bar')
      @something.foo
    end
  end

  describe "rebuilding" do
    before do
      @events = [
        OpenStruct.new(event: "foo_happened", arguments: "one"),
        OpenStruct.new(event: "foo_happened", arguments: "two")
      ]
    end

    it "raises an error when not found" do
      Replay::EventStore.expects(:find_model_events).with(999).returns([])
      lambda{ ReplayTestClass.find(999) }.must_raise EntityNotFoundError
    end

    it "replays internal state" do
      Replay::EventStore.expects(:find_model_events).with(1).returns(@events)
      something = ReplayTestClass.find(1)
      something.bar_value.must_equal "two"
    end

    it "has its id" do
      Replay::EventStore.expects(:find_model_events).with(133).returns(@events)
      something = ReplayTestClass.find(133)
      something.id.must_equal 133
    end
  end

  describe "applying an event" do
    it "changes state" do
      @something.foo
      @something.bar_value.must_equal "bar"
    end
  end

end

