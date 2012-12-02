require './test/spec_helper'

::ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "test/test_events.sqlite3"
)
::ActiveRecord::Base.connection.execute("create table if not exists replay_events(id primary key, event, model_id, arguments, created_at, updated_at)")

describe Replay::ActiveRecordEventStore do
  before do
    @store = Replay::ActiveRecordEventStore.new
  end

  def action(model_id = 123)
    @store.store(:foo_event, model_id, 'bar')
  end

  describe "#store" do
    it "should create an event in the database" do
      count = Replay::ActiveRecordEvent.count
      action
      (Replay::ActiveRecordEvent.count - count).must_equal 1
    end
  end

  describe "#find_model_events" do
    before do
      Replay::ActiveRecordEvent.delete_all
    end

    it "should be empty" do
      @store.find_model_events(111).length.must_equal 0
    end

    it "should find events" do
      action(456)
      action(7890)
      action(456)
      @store.find_model_events(456).length.must_equal 2
      @store.find_model_events(7890).length.must_equal 1
    end
  end
end