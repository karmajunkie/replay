require_relative "../proofs_init.rb"
require 'replay/test'

module Replay::SubscriptionManager::Proof
  def only_adds_legit_subs
    begin
      add_subscriber(Object.new)
    rescue Replay::InvalidSubscriberError => e
      return true
    end
    false
  end

  def sub_gets_notified
    sub = Class.new do
      attr_accessor :stream, :event
      def published(envelope)
        self.stream = envelope.stream_id
        self.event = envelope.event
      end
    end.new
    add_subscriber(sub)
    notify_subscribers "123", "456"
    sub.stream == '123' && sub.event == '456'
  end
end

title "Subscription Manager"

proof "raises InvalidSubscriberError when subscriber fails to implement #published" do
  sm = Replay::SubscriptionManager.new
  sm.prove { only_adds_legit_subs }
end

proof "notifies proper subscriber when informed" do
  sm = Replay::SubscriptionManager.new
  sm.prove { sub_gets_notified }
end

