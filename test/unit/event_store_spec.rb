require './test/spec_helper'

describe Replay::EventStore do
  before do
    Replay::EventStore.configure do |config|
      config.storage = Replay::TestStorage.new
    end
  end
  after do
    Replay::EventStore.clear_listeners
  end
  describe "#handle_event" do
    def action
      Replay::EventStore.handle_event(:foo_event, 123, {:bar => "fly"})
    end
    it "stores the event" do
      Replay::TestStorage.any_instance.expects(:store).with(:foo_event, 123, {:bar => "fly"} )
      action
    end
    it "notifies listeners" do
      listener = mock("listener") do
        expects(:handle_event).with(:foo_event, 123, {:bar => 'fly'})
      end
      Replay::EventStore.add_listener(:foo_event, listener)
      action
    end
  end
end