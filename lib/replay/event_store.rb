module Replay
  class EventStore
    class << self
      attr_accessor :configuration
      attr_accessor :listeners
    end
    self.listeners = {}
    self.configuration = Replay::Configuration.new

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

    def self.handle_event(event, model_id, *args)
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
  end
end