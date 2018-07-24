$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lhc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lhc"
  s.version     = LHC::VERSION
  s.authors     = ['https://github.com/local-ch/lhc/contributors']
  s.email       = ['web@localsearch.ch']
  s.homepage    = 'https://github.com/local-ch/lhc'
  s.summary     = 'Advanced HTTP Client for Ruby, fueled with interceptors'
  s.description = 'Advanced HTTP Client for Ruby, fueled with interceptors'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 2.0.0'
  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'activesupport', '>= 4.2'
  s.add_dependency 'addressable'
  s.add_dependency 'typhoeus', '>= 0.11'

  s.add_development_dependency 'geminabox'
  s.add_development_dependency 'prometheus-client', '~> 0.7.1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails', '~> 4.2'
  s.add_development_dependency 'rspec-rails', '>= 3.0.0'
  s.add_development_dependency 'rubocop', '~> 0.57.1'
  s.add_development_dependency 'rubocop-rspec', '~> 1.26.0'
  s.add_development_dependency 'webmock'

  s.license = 'GPL-3'
end
