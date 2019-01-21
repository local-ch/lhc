# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    LHC::Config.instance.reset
  end
end
