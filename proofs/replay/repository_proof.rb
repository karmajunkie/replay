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

