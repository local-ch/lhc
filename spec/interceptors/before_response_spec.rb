require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class SomeInterceptor < LHC::Interceptor

        def before_response
        end
      end
    end

    it 'can perform some actions before a reponse is received' do
      interceptor = LHC::InterceptorProcessor.interceptors.first
      expect(interceptor).to receive(:before_response)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end
  end
end
