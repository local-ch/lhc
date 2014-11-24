$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lhc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lhc"
  s.version     = LHC::VERSION
  s.authors     = ['local.ch']
  s.email       = ['ws-operations@local.ch']
  s.homepage    = 'https://github.com/local-ch/lhc'
  s.summary     = 'LocalHttpServices'
  s.description = 'Rails gem wrapping typhoeus and providing additional features (like interceptors)'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 1.9.2'
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'typhoeus'
  s.add_development_dependency 'pry-byebug'
end
