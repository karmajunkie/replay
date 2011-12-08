module Replay
  class EventStore
    class << self
      attr_accessor :configuration
      attr_accessor :listeners
    end
    self.listeners = {}

    def self.configure(&block)
      self.configuration = Replay::Configuration.new
      block.call(self.configuration)
    end

    def self.storage
      configuration.storage
    end

    def self.add_listener(event, new_listener)
      self.listeners[event] = [] unless self.listeners[event]
      self.listeners[event] << new_listener
    end

    def self.handle_event(event, model_id, *args)
      configuration.storage.each do |event_store_adapter|
        event_store_adapter.store(event, model_id, *args)
      end
      debugger
      if self.listeners[event]
        self.listeners[event].each do |listener|
          listener.handle_event(event, model_id, *args)
        end
      end
    end
  end
end