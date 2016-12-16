require 'rails_helper'

describe LHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < LHC::Interceptor
        def after_request(request); end
      end
      LHC.configure { |c| c.interceptors = [SomeInterceptor] }
    end

    it 'can perform some actions after a request was fired' do
      expect_any_instance_of(SomeInterceptor).to receive(:after_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end
  end
end
