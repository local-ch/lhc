# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  let(:request_options) do
    [
      { url: 'http://www.local.ch/restaurants' },
      { url: 'http://www.local.ch' }
    ]
  end

  let(:stub_parallel_requests) do
    stub_request(:get, "http://www.local.ch/restaurants").to_return(status: 200, body: '1')
    stub_request(:get, "http://www.local.ch").to_return(status: 200, body: '2')
  end

  it 'does parallel requests if you provide an array of requests' do
    stub_parallel_requests
    responses = LHC.request(request_options)
    expect(responses[0].body).to eq '1'
    expect(responses[1].body).to eq '2'
  end

  context 'interceptors' do
    before(:each) do
      class TestInterceptor < LHC::Interceptor; end
      LHC.configure { |c| c.interceptors = [TestInterceptor] }
    end

    it 'calls interceptors also for parallel requests' do
      stub_parallel_requests
      @called = 0
      allow_any_instance_of(TestInterceptor)
        .to receive(:before_request) { @called += 1 }
      LHC.request(request_options)
      expect(@called).to eq 2
    end
  end

  context 'webmock disabled' do
    before do
      WebMock.disable!
    end

    after do
      WebMock.enable!
    end

    it 'does not memorize parallelization handlers in typhoeus (hydra) in case one request of the parallization fails' do
      begin
        LHC.request([{ url: 'https://www.google.com/' }, { url: 'https://nonexisting123' }, { url: 'https://www.google.com/' }, { url: 'https://nonexisting123' }])
      rescue LHC::UnknownError
      end

      LHC.request([{ url: 'https://www.google.com' }])
    end
  end
end
