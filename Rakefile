require "bundler/gem_tasks"
require 'rake/testtask'

task :prove_all do
  Bundler.setup
  Bundler.require :default
  require_relative "proofs/all"
end
Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "test"
  t.test_files = FileList['test/**/*_spec.rb']
  t.verbose = true
end

task :default => [:test, :prove_all]
