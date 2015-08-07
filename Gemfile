source 'https://GemInAbox:e3XRBgVJRNUmwJ5y@gembox-vm-inx01.intra.local.ch/'

# Declare your gem's dependencies in lhc.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'rspec-rails', '>= 3.0.0'
gem 'rails', '~> 4.1.1'
gem 'pry'
gem 'typhoeus', git: 'git@github.com:local-ch/typhoeus.git', branch: 'improved-timeouts'
gem 'webmock', group: [:test]

group :development do
  gem 'geminabox'
end