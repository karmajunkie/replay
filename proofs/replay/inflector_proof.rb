require_relative "../proofs_init.rb"
require 'replay/inflector'

module Replay::Inflector::Proof 
  def camelizes?(flat, cameld)
    Replay::Inflector.camelize(flat) == cameld
  end
  def underscores?(from, to)
    Replay::Inflector.underscore(from) == to
  end
end
Replay::Inflector.extend(Replay::Inflector::Proof)

title "Replay::Inflector"

proof "camelize camel-cases a string" do
  #Replay::Inflector.prove{ camelizes?("replay.test", "Replay::Test")}
end

proof "underscore transforms a classname to 'module.class'" do
  Replay::Inflector.prove{ underscores?("Replay::Test", 'replay.test')}
  Replay::Inflector.prove{ underscores?("ReplayTest::Test", 'replay_test.test')}
  Replay::Inflector.prove{ underscores?("Replay2Test::Test", 'replay2_test.test')}
  Replay::Inflector.prove{ underscores?("Replay::TestData", 'replay.test_data')}
end
