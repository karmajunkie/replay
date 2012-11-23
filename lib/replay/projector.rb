module Replay::Projector
  extend ActiveSupport::Concern

  included do
    self.extend(ClassMethods)
    self.listening_blocks = HashWithIndifferentAccess.new
  end

  module ClassMethods
    def listen(event, &block)
      listening_blocks[event] = [] unless listening_blocks[event]
      listening_blocks[event] << block
      Replay::EventStore.add_listener(event, self)
    end

    def handle_event(event, model_id, *args)
      raise EventNotRegisteredError.new(event) unless listening_blocks[event]

      listening_blocks[event].each do |block|
        block.call(model_id, *args)
      end
    end

    private
    attr_accessor :listening_blocks
  end
end