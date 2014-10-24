RSpec.configure do |config|

  config.before(:each) do
    LHC::InterceptorProcessor.interceptors.each do |interceptor|
      interceptor.class.opt = :out # reset to default
      Object.send(:remove_const, interceptor.class.name.to_sym)
    end
    LHC::InterceptorProcessor.interceptors = []
  end
end
