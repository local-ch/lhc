require 'rails_helper'

describe LHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < LHC::Interceptor
        def before_response(request)
        end
      end
      LHC.configure { |c| c.interceptors = [SomeInterceptor] }
    end

    it 'can perform some actions before a reponse is received' do
      expect_any_instance_of(SomeInterceptor).to receive(:before_response)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end
  end
end
