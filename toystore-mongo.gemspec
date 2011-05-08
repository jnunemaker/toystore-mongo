# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "toy/mongo/version"

Gem::Specification.new do |s|
  s.name        = "toystore-mongo"
  s.version     = Toy::Mongo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['John Nunemaker']
  s.email       = ['nunemaker@gmail.com']
  s.homepage    = ''
  s.summary     = %q{Mongo integration for Toystore}
  s.description = %q{Mongo integration for Toystore}

  s.add_dependency('plucky', '~> 0.4.0')
  s.add_dependency('toystore', '~> 0.6.5')
  s.add_dependency('adapter-mongo', '~> 0.5.2')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
