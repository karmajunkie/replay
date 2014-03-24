require 'replay'
require 'replay/test/test_event_stream'

module Replay::EventExaminer
  def events
    @_events
  end
  def published?(event)
    @_events.detect{|e| event.is_a?(Class) ? e.class == event : e == event}
  end

  def initialize()
    @_events ||= []
    super
  end

  def self.extended(object)
    object.instance_variable_set(:@_events, [])
  end

  def apply(events, raise_unhandled = true)
    return apply([events], raise_unhandled) unless events.is_a?(Array)
    super(events, raise_unhandled)
    events.each do |event|
      @_events << event
    end
  end
end

Replay::Publisher::ClassMethods.module_exec do
  def self.extended(base)
    @publishers ||= []
    @publishers << base
    base.send(:include, Replay::EventExaminer)
  end
end
