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
    self.instance_exec(*args, &event_block)
  end

  def event_blocks
    self.class.event_blocks
  end

  module ClassMethods
    def apply(event, &block)
      event_blocks[event.to_sym] = block
    end

    attr_accessor :event_blocks
  end
end