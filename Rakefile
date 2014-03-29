require "bundler/gem_tasks"

task :prove_all do
  Bundler.setup
  Bundler.require :default
  require_relative "proofs/all"
end

task :default => :prove_all
