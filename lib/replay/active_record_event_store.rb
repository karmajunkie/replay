if defined?(ActiveRecord)
  module Replay
    class ActiveRecordEvent < ::ActiveRecord::Base
      self.table_name = "replay_events"
      serialize :arguments
    end

    #needs model id
    class ActiveRecordEventLogEntry < ::ActiveRecord::Base
      self.table_name = "replay_event_log_entries"
      serialize :data
    end

    class ActiveRecordEventStore
      def store(event, model_id, *args)
        ar_event = Replay::ActiveRecordEvent.new
        ar_event.event = event
        ar_event.model_id = model_id
        ar_event.arguments = args
        ar_event.save
      end

      def log_event(event, model_id, *args)
        log_entry = Replay::ActiveRecordEventLogEntry.new
        log_entry.event = event
        log_entry.model_id = model_id
        log_entry.data = args
        log_entry.save
      end
    end
  end
end
