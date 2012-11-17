module Replay
  class TestStorage
    # To change this template use File | Settings | File Templates.
    def store(event, id, *args)
      true
    end

    def find_model_events(model_id)
      [] # stub as needed
    end
  end
end