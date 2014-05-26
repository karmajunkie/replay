module Replay
  class Configuration
    attr_accessor :storage
    attr_writer :reject_load_on_empty_stream

    def storage=(stores)
      stores = [stores] unless stores.is_a?(Array)
      @storage = stores
    end

    def reject_load_on_empty_stream?
      @reject_load_on_empty_stream ||= true
      @reject_load_on_empty_stream
    end
  end
end
