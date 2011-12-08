module Replay::Projector
  extend ActiveSupport::Concern

  included do
    self.extend(ClassMethods)
    self.listening_blocks = {}
  end

  module ClassMethods
    def listen(event, &block)
      listening_blocks[event] = [] unless listening_blocks[event]
      listening_blocks[event] << block
      Replay::EventStore.add_listener(event, self)
    end

    private
    attr_accessor :listening_blocks
  end
end