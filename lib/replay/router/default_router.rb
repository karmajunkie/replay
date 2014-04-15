module Replay
  module Router
    class DefaultRouter
      include Singleton
      include Replay::Router
    end
  end
end

Replay::Backends.register(:replay_router, Replay::Router::DefaultRouter)
