require 'replay'

module Replay::EventExaminer
  def events
    @_events ||= []
  end

  def published?(event, fuzzy=false)
    if fuzzy
      !(events.detect{|e| event.kind_of_matches?(e) }.nil?)
    else
      events.detect{|e| event.is_a?(Class) ? e.class == event : e == event}
    end
  end

  def similar_events(event)
    events.select{|e| e.class == event.class}
  end

  def apply(events, raise_unhandled = true)
    return apply([events], raise_unhandled) unless events.is_a?(Array)
    retval = super(events, raise_unhandled)
    events.each do |event|
      self.events << event
    end
    return retval
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

Replay::Router.module_exec do 
  def inspect
    self.class.to_s 
  end

  def observed_by?(object)
    @subscription_manager.has_subscriber?(object)
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

    keys_self = relevant_attrs_self.keys
    if (relevant_attrs_self.keys - relevant_attrs_match.keys).empty?
      #publication time is not considered part of the event data
      if keys_self.reject{|k| event[k] == self[k]}.any?
        return false
      else
        return true
      end
    else
      return false
    end
  end
end
