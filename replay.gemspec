# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "replay/version"

Gem::Specification.new do |s|
  s.name        = "replay"
  s.version     = Replay::VERSION
  s.authors     = ["karmajunkie"]
  s.email       = ["keith.gaddis@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Replay supports event-sourced data models.}
  s.description = %q{Replay supports event-sourced data models.}

  s.rubyforge_project = "replay"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "activesupport"
end
