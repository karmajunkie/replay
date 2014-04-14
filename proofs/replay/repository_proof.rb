require_relative "../proofs_init.rb"
require 'replay/test'

class Subscriber
  def published(stream_id, event); end
end

class RepositoryTest
  include Replay::Repository
  include Singleton

  class << self
    attr_accessor :proven
  end

  def self.can_be_configured
    self.configure do |config|
      self.proven = true
    end

    self.proven
  end
end

title "Repository interface"

proof "repository can be configured" do
  RepositoryTest.prove {can_be_configured }
end

Proof::Output.class_exec do 
  writer :pending, :level => :info do |text|
    prefix :pending, "PENDING: #{text}"
  end
end

def pending(text = "pending test")
  Proof::Output.pending "pending test"
end
proof "loads an instance of supplied class" do; pending; end
proof "load raises an error if event stream isn't found" do; pending; end
proof "load returns uncreated instance when :create is pending" do; false; end
proof "load returns a created instance when :create is true" do; pending; end

proof "reload returns the supplied instance in its current state" do; pending; end

