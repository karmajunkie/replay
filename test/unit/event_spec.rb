require './test/spec_helper'

describe Replay::Event do
  before do
    @event = Replay::Event.new("shit_happened", :foo => :bar)
  end

  describe "method_missing" do
    it "fakes the reader" do
      @event.foo.must_equal :bar
    end
  end
end
