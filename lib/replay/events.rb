
module Replay
  module Events
    def self.extended(base)
      base.extend(ClassMethods)
    end
    def self.included(base)
      base.extend(ClassMethods)
      #self.constants.each{|c| base.const_set(c, const_get(c))}
    end
    module ClassMethods
      def events(mod = nil, &block)
        unless mod
          mod = Module.new do
            extend Replay::EventDeclarations
            module_eval &block
          end
          self.const_set(:"#{self.to_s.split("::")[-1]}Events", mod)
        end
        include mod
      end
    end

  end
end
