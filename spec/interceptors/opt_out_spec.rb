require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class SomeInterceptor < LHC::Interceptor
      end
    end

    let(:interceptor) { LHC::InterceptorProcessor.interceptors.first }

    it 'is using interceptors globally when they not opt_out in request' do
      expect(interceptor).to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end

    it 'is not using interceptors flagged with opt_out in request' do
      expect(interceptor).not_to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch', opt_out: :some_interceptor)
    end
  end
end
