require 'rails_helper'

describe LHC::Caching do
  before(:each) do
    LHC.config.interceptors = [LHC::Caching]
    LHC.config.endpoint(:local, 'http://local.ch', cache: true, cache_expires_in: 5.minutes)
    Rails.cache.clear
    # leverage the Typhoeus internal mock attribute in order to get Typhoeus evaluate the return_code
    # lib/typhoeus/response/status.rb:48
    allow_any_instance_of(Typhoeus::Response).to receive(:mock).and_return(false)
  end

  let!(:stub) { stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website') }

  it 'provides the correct response status for responses from cache' do
    stub
    # the real request provides the return_code
    allow_any_instance_of(Typhoeus::Response).to receive(:options)
      .and_return(code: 200, status_message: '', body: 'The Website', headers: nil, return_code: :ok)
    response = LHC.get(:local)
    expect(response.success?).to eq true
    # the cached response should get it from the cache
    allow_any_instance_of(Typhoeus::Response).to receive(:options).and_call_original
    cached_response = LHC.get(:local)
    expect(cached_response.success?).to eq true
  end
end
