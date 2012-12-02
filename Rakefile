require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  # shell out each test on its own process
  # domain unit tests fail when running in a batch
  Dir.glob('test/**/*_spec.rb').each do |spec|
    result = system("ruby #{spec}")
    raise "Abort: encountered failing test" unless result
  end
end
