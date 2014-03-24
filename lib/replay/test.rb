require 'replay'
require 'replay/test/test_event_stream'

module Replay::EventExaminer
  def events
    @_events
  end
  def published?(event, fuzzy=false)
    if fuzzy
      @_events.detect{|e| event.is_a?(Class) ? e.class == event : e == event}
    else
      @_events
    end
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

  def has_subscriber?(subscriber)
    @subscription_manager.has_subscriber?(subscriber)
  end
end

Replay::SubscriptionManager.class_exec do
  def has_subscriber?(subscriber)
    @subscribers.include?(subscriber)
  end
end

Replay::Publisher::ClassMethods.module_exec do
  def self.extended(base)
    @publishers ||= []
    @publishers << base
    base.send(:include, Replay::EventExaminer)
  end
end

Replay::EventDecorator.module_exec do
  #receiver's non-nil values are a subset of parameters non-nil values
  def kind_of_matches?(event)
    relevant_attrs_match = event.attributes.reject{|k,v| v.nil?}
    relevant_attrs_self = self.attributes.reject{|k,v| v.nil?}

    if (relevant_attrs_self.keys - relevant_attrs_match.keys).empty?
      if relevant_attrs_self.reject{|k, v| event[k] == v}.any?
        return false
      else
        return true
      end
    else
      return false
    end
  end
end
