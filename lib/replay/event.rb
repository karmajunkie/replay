module Replay
  class Event
    attr_accessor :event_type, :attributes

    def initialize(event_type, *data)
      @event_type = event_type
      if data.first.kind_of? Hash
        @attributes = HashWithIndifferentAccess.new data.first.dup
      else
        @attributes = HashWithIndifferentAccess.new({data.first => data.last})
      end
    end

    def method_missing(method, *args)
      method_root = method.to_s.gsub(/=$/, "")
      if @attributes && @attributes.has_key?(method_root)
        if method.to_s[/=$/]
          @attributes[method_root] = args.first
        else
          @attributes[method]
        end
      else
        nil
      end
    end
  end
end
