if defined?(RSpec)
  RSpec.configure do |config|
    LHC::Caching.cache = ActiveSupport::Cache::MemoryStore.new

    config.before(:each) do
      LHC::Caching.cache.clear
    end
  end
end
