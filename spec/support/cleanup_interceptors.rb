RSpec.configure do |config|

  config.before(:each) do
    LHC::Interceptor.interceptors.each do |interceptor|
      interceptor.class.opt = :out # reset to default
      Object.send(:remove_const, interceptor.class.name.to_sym)
    end
    LHC::Interceptor.interceptors = []
  end
end
