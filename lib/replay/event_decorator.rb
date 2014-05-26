module Replay
  #hook class to apply global decorators to events
  module EventDecorator 
    def self.included(base)
      base.class_eval do 
        include Virtus.value_object
        attr_accessor :metadata
        def inspect
          "#{self.type}: #{self.attributes.map{|k, v| "#{k.to_s} = #{v.to_s}"}.join(", ")}"
        end
        def type
          self.class.to_s
        end
      end
    end
  end
end
