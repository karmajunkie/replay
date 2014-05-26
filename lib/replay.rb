require 'virtus'

module Replay
  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  class ReplayError            < StandardError; end
  class UndefinedKeyError      < ReplayError; end
  class UnhandledEventError    < ReplayError; end
  class UnknownEventError      < ReplayError; end
  class InvalidRouterError     < ReplayError; end
  class InvalidStorageError    < ReplayError;
    def initialize(*args)
      klass = args.shift
      super( "Storage #{klass.to_s} does not implement #event_stream(stream, event)", *args)
    end
  end
  class InvalidSubscriberError < ReplayError;
    def initialize(*args)
      obj = args.shift
      super( "Subscriber#{obj.to_s} does not implement #published(stream, event)", *args)
    end
  end
end

require 'replay/inflector'
require 'replay/events'
require 'replay/event_decorator'
require 'replay/event_declarations'
require 'replay/event_envelope'
require 'replay/publisher'
require 'replay/subscription_manager'
require 'replay/subscriptions'
require 'replay/backends'
require 'replay/repository'
require 'replay/repository/identity_map'
require 'replay/repository/configuration'
require 'replay/observer'
require 'replay/router'
require 'replay/router/default_router'

