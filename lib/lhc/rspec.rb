# frozen_string_literal: true

require 'lhc'

RSpec.configure do |config|
  config.before(:each) do
    LHC::Caching.cache = ActiveSupport::Cache::MemoryStore.new
    LHC::Caching.cache.clear
    LHC::Throttle.track = nil
  end
end
