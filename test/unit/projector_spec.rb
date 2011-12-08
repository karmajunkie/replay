require './test/spec_helper'

describe Replay::Projector do
  after do
    Replay::EventStore.clear_listeners
  end

  describe "#listen" do
    it "adds the class as a listener to the EventStore" do
      class ProjectorExample
        Replay::EventStore.expects(:add_listener).with(:foo_happened, self)

        include Replay::Projector
        listen :foo_happened do |model_id, arg|
        end
      end
    end
  end
end