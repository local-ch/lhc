require 'rails_helper'

describe LHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < LHC::Interceptor
      end
      class AnotherInterceptor < LHC::Interceptor
      end
    end

    it 'performs interceptor when they are set globally' do
      LHC.configure { |c| c.interceptors = [SomeInterceptor] }
      expect_any_instance_of(SomeInterceptor).to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end

    it 'overrides interceptors on request level' do
      LHC.configure { |c| c.interceptors = [SomeInterceptor] }
      expect_any_instance_of(AnotherInterceptor).to receive(:before_request)
      expect_any_instance_of(SomeInterceptor).not_to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch', interceptors: [AnotherInterceptor])
    end
  end
end
