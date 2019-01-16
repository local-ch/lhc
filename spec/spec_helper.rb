# frozen_string_literal: true

require 'pry'
require 'webmock/rspec'
require 'lhc'

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }
