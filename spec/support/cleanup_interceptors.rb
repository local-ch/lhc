RSpec.configure do |config|

  config.before(:each) do
    LHC.default_interceptors = nil
  end
end
