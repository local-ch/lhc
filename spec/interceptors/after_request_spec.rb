require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class SomeInterceptor < LHC::Interceptor

        def after_request(request)
        end
      end
    end

    it 'can perform some actions after a request was fired' do
      interceptor = LHC::Interceptor.interceptors.first
      expect(interceptor).to receive(:after_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end
  end
end
