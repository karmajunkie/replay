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
  def action
    @store.store(:foo_event, 123, 'bar')
  end
  describe "#store" do
    it "should create an event in the database" do
      count = Replay::ActiveRecordEvent.count
      action
      (Replay::ActiveRecordEvent.count - count).must_equal 1
    end

  end
end