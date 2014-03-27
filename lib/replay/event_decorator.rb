module Replay
  #hook class to apply global decorators to events
  module EventDecorator 
    def self.included(base)
      base.class_eval do 
        include Virtus.value_object
        def inspect
          "#{self.class.to_s}: #{self.attributes.map{|k, v| "#{k.to_s} = #{v.to_s}"}.join(", ")}"
        end
      end
    end
  end
end
