module Replay
  class Configuration
    attr_accessor :storage

    def storage=(stores)
      stores = [stores] unless stores.is_a?(Array)
      @storage = stores
    end
  end
end