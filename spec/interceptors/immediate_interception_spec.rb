require 'rails_helper'

describe LHC do

  context 'interceptor' do

    let(:body) do
      'im served from cache'
    end

    let(:response) do
      Typhoeus::Response.new(response_body: body)
    end

    before(:each) do

      class CacheInterceptor < LHC::Interceptor
        cattr_accessor :response

        def before_request(request)
          raise LHC::ImmediateInterception.new('Serve cached response', response) if request.url == 'http://local.ch'
        end
      end

      CacheInterceptor.response = response

      class AnotherInterceptor < LHC::Interceptor
        def before_request(request); end
      end
    end

    it 'is intercepting immediately and injects a response that will be returned instead (caching)' do
      another_interceptor = LHC::Interceptor.interceptors.last
      expect(another_interceptor).not_to receive(:before_response)
      stub_request(:get, 'http://local.ch')
      response = LHC.get('http://local.ch')
      expect(response.body).to eq body
    end
  end
end
