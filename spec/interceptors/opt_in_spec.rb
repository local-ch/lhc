require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class SomeInterceptor < LHC::Interceptor
        opt_in
      end
    end

    let(:interceptor) { LHC::Interceptor.interceptors.first }

    it 'is not using interceptors globally when they are flagged with opt_in' do
      expect(interceptor).not_to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch')
    end

    it 'is using interceptors flagged with opt_in when you opt_in them for a request' do
      expect(interceptor).to receive(:before_request)
      stub_request(:get, 'http://local.ch')
      LHC.get('http://local.ch', opt_in: :some_interceptor)
    end
  end
end
