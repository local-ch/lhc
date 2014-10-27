require 'rails_helper'

describe LHC do

  context 'interceptor' do

    let(:body) do
      'im served from cache'
    end

    let(:response) do
      Typhoeus::Response.new(response_body: body)
    end

    context 'immediate return of response' do

      before(:each) do
        class ImmidateCacheInterceptor < LHC::Interceptor
          cattr_accessor :response

          def before_request(request)
            return_response!(response) if request.url == 'http://local.ch'
          end
        end
        ImmidateCacheInterceptor.response = response
        class SomeInterceptor < LHC::Interceptor
          def before_request(request); end
        end
      end

      it 'is intercepting immediately and injects a response that will be returned instead (caching)' do
        another_interceptor = LHC::InterceptorProcessor.interceptors.find{|i| ! i.is_a? ImmidateCacheInterceptor }
        expect(another_interceptor).not_to receive(:before_response)
        response = LHC.get('http://local.ch')
        expect(response.body).to eq body
      end
    end

    context 'return response for the usual return' do

      before(:each) do
        class CacheInterceptor < LHC::Interceptor
          cattr_accessor :response

          def before_request(request)
            return_response(response) if request.url == 'http://local.ch'
          end
        end
        CacheInterceptor.response = response
        class SomeInterceptor < LHC::Interceptor
          def before_request(request);end
        end
      end

      it 'is intercepting immediately and injects a response that will be returned instead (caching)' do
        another_interceptor = LHC::InterceptorProcessor.interceptors.find{|i| ! i.is_a? CacheInterceptor }
        expect(another_interceptor).to receive(:before_request)
        response = LHC.get('http://local.ch')
        expect(response.body).to eq body
      end
    end

    context 'misusage' do

      before(:each) do
        class CacheInterceptor < LHC::Interceptor
          def before_request(request)
            return_response(Typhoeus::Response.new({}))
          end
        end
        class AnotherInterceptor < LHC::Interceptor
          def before_request(request)
            return_response(Typhoeus::Response.new({}))
          end
        end
      end

      it 'raises an exception when two interceptors try to return a response' do
        expect(->{
          LHC.get('http://local.ch')
        }).to raise_error 'Response already set from another interceptor'
      end
    end
  end
end
