module Replay::Domain
  extend ActiveSupport::Concern
  include Replay

  included do
    self.extend ClassMethods
    self.event_blocks = {}
  end

  def signal_event(event, *args)
    EventStore.handle_event(event, self.id, *args)
    apply_event(event, *args)
  end

  def apply_event(event, *args)
    event_block = event_blocks[event.to_sym]
    raise UnknownEventError.new("#{event} is not a known event on class #{self.class.name}") unless event_block
    EventStore.log_event(event, self.id, *args)
    self.instance_exec(*args, &event_block)
  end

  def event_blocks
    self.class.event_blocks
  end

  module ClassMethods
    def find(model_id)
      events = Replay::EventStore.find_model_events(model_id)
      raise EntityNotFoundError.new("No model found for #{model_id}") if events.length == 0

      instance = self.new_replay(model_id)
      events.each do |e|
        event_block = event_blocks[e.event.to_sym]
        args = e.arguments
        instance.instance_exec(*args, &event_block)
      end
      instance
    end

    def new_replay(model_id)
      instance = self.new
      instance.send("id=".to_sym, model_id)
      instance
    end

    def apply(event, &block)
      event_blocks[event.to_sym] = block
    end

    attr_accessor :event_blocks
  end
end