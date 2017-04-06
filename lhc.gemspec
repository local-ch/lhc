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
  s.summary     = 'LocalHttpClient'
  s.description = 'Rails gem for HTTP: Wraps typhoeus and provides additional features (like interceptors)'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n") +
                   `git ls-files -- non_rails_spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 1.9.2'
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'typhoeus'
  s.add_dependency 'activesupport', '>= 4.1'

  s.add_development_dependency 'rspec-rails', '>= 3.0.0'
  s.add_development_dependency 'rails', '~> 4.1.1'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'geminabox'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop', '~> 0.36.0'
  s.add_development_dependency 'rubocop-rspec'
  
  s.license = 'GPL-3'
end
