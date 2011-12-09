if defined?(ActiveRecord)
  module Replay
    class AREvent < ::ActiveRecord::Base
      set_table_name "replay_events"
      serialize :arguments
    end
    class ActiveRecordEventStore
      def store(event, model_id, *args)
        ar_event = Replay::AREvent.new
        ar_event.event = event
        ar_event.model_id = model_id
        ar_event.arguments = args
        ar_event.save
      end
    end
  end
end