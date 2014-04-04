require_relative "../proofs_init.rb"
require 'replay/test'

class Subscriber
  def published(stream_id, event); end
end

module Replay::Repository::Configuration::Proof
  def can_configure_store?
    self.store = :memory
    self.store == Replay::Backends::MemoryStore
  end

  def can_add_default_subscriber?
    sub = Subscriber.new
    self.add_default_subscriber sub
    subscribers.include? sub
  end

  def subscribers_include_store
    self.store = :memory
    self.subscribers.include? Replay::Backends::MemoryStore
  end

  def requires_store_to_act_like_subscriber
    begin
      store = Class.new do
        def self.event_stream(stream); end
      end
      self.store = store
    rescue Replay::InvalidSubscriberError => e
      return true
    rescue Exception  => e
    end
    false
  end

  def requires_store_to_load_events
    begin
      self.store = Subscriber.new 
    rescue Replay::InvalidStorageError
      return true
    rescue Exception  => e
    end
    false
  end
end

proof "can configure a store" do
  Replay::Repository::Configuration.new.prove {can_configure_store?}
end

proof 'adding a store adds it as a subscriber' do
  Replay::Repository::Configuration.new.prove { subscribers_include_store }
end

proof "can configure a default_subscriber" do
  Replay::Repository::Configuration.new.prove {can_add_default_subscriber?}
end

proof "raises error if store won't load events" do
  Replay::Repository::Configuration.new.prove {requires_store_to_load_events }
end

proof "raises error if store won't act like a subscriber" do
  Replay::Repository::Configuration.new.prove {requires_store_to_act_like_subscriber }
end
