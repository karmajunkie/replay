require_relative 'proofs_init.rb'

files = Dir.glob(File.join(File.dirname(__FILE__), '**/*_proof.rb'))
puts files
Proof::Suite.run "replay/**/*.rb"


