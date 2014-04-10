module Replay
  module EventDeclarations
    def self.included(base)
      base.extend(Replay::Events)
    end

    def included(base)
      self.constants.each do |c| 
        base.const_set(c, const_get(c).dup)
        klass = base.const_get(c)
        base.class_eval do
          define_method c do |props|
            klass.new props
          end
        end
      end
    end
    def method_missing(name, *args)
      declare_event(self, name, args.first)
    end

    def declare_event(base, name, props)
      klass = Class.new do
        include Replay::EventDecorator
        attribute :published_at, Time, default: lambda{|p,a| Time.now}
        values do
          props.keys.each do |prop|
            attribute prop, props[prop]
          end
        end
        include Virtus::Equalizer.new("#{name.to_s} equalizer", (self.attribute_set.map(&:name) - [:published_at]).map(&:to_s))
      end
      base.const_set name, klass
    end
  end
end
