module Replay
  class Event
    attr_accessor :event_type, :data

    def initialize(event_type, data = {})
      self.event_type = event_type
      self.data = data
    end

    def method_missing(method, *args)
      method_root = method.to_s.gsub(/=$/, "")
      if data && data.has_key?(method_root)
        if method.to_s[/=$/]
          self.data[method_root] = args.first
        else
          self.data[method]
        end
      else
        nil
      end
    end
  end
end