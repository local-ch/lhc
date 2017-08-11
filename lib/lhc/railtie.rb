module LHC
  class Railtie < Rails::Railtie
    initializer "lhc.configure_rails_initialization" do
      LHC::Caching.default_cache ||= Rails.cache
      LHC::Caching.logger ||= Rails.logger
    end
  end
end
