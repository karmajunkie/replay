require './test/spec_helper'

describe Replay do
  class ReplayTestClass
    include Replay

    attr_accessor :bar_value

    def id
      1
    end

    def foo
      signal_event :foo_happened, "bar"
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

  end

  describe "applying an event" do
    it "changes state" do
      @something.foo
      @something.bar_value.must_equal "bar"
    end
  end


end

