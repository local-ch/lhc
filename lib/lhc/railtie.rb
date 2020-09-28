# frozen_string_literal: true

module LHC
  class Railtie < Rails::Railtie
    initializer "lhc.configure_rails_initialization" do
      LHC::Caching.cache ||= Rails.cache
    end
  end
end
