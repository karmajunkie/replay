module Replay
  #hook class to apply global decorators to events
  module EventDecorator 
    def self.included(base)
      base.class_eval do 
        include Virtus.value_object
      end
    end
  end
end
