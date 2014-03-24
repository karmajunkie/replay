require_relative "../proofs_init.rb"
require 'replay/test'

desc "proof for the test support provided by replay"

title "Test support"

proof "fuzzy matching of events" do
  class TestEvent
    include Replay::EventDecorator
    
    values do
      attribute :one, String
      attribute :two, String
    end

    def matches_fuzzy(event)
      self.kind_of_matches?(event)
    end
  end

  e1 = TestEvent.new(one: '1')
  e2 = TestEvent.new(one: '1', two: '2')

  e1.prove{ matches_fuzzy(e2)}
  e2.prove{ !matches_fuzzy(e1)}

end
