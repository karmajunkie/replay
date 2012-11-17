module Replay
  class EventStore
    include Replay

    class << self
      attr_accessor :configuration
      attr_accessor :listeners
      attr_accessor :test_mode
      attr_accessor :event_stream
    end
    self.listeners = {}
    self.configuration = Replay::Configuration.new
    self.event_stream = []

    def self.configure(&block)
      block.call(self.configuration)
    end

    def self.storage
      configuration.storage
    end

    def self.add_listener(event, new_listener)
      self.listeners[event] = [] unless self.listeners[event]
      self.listeners[event] << new_listener
    end

    def self.clear_listeners
      listeners = {}
    end

    def self.log_event(event, model_id, *args)
      if configuration.storage
        configuration.storage.each do |event_store_adapter|
          event_store_adapter.log_event(event, model_id, *args)
        end
      end
    end

    def self.handle_event(event, model_id, *args)
      self.event_stream << Event.new(event, args.last) if self.test_mode

      if configuration.storage
        configuration.storage.each do |event_store_adapter|
          event_store_adapter.store(event, model_id, *args)
        end
      end
      if self.listeners[event]
        self.listeners[event].each do |listener|
          listener.handle_event(event, model_id, *args)
        end
      end
    end

    def self.find_model_events(model_id)
      if configuration.storage
        configuration.storage.each do |event_store_adapter|
          # TODO: need a primary storage for replays ????
          # this just uses first one found
          return event_store_adapter.find_model_events(model_id)
        end
      end
      raise "no storage configured"
    end
  end
end