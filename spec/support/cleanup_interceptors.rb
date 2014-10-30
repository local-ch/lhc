RSpec.configure do |config|

  config.before(:each) do
    LHC.default_interceptors = []
  end
end
