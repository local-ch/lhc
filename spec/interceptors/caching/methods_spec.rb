require 'rails_helper'

describe LHC::Caching do
  before(:each) do
    LHC.config.interceptors = [LHC::Caching]
    LHC::Caching.cache = Rails.cache
    Rails.cache.clear
  end

  let!(:stub) { stub_request(:post, 'http://local.ch').to_return(status: 200, body: 'The Website') }

  before(:each) do
    LHC.config.endpoint(:local, 'http://local.ch', cache: true, cache_expires_in: 5.minutes)
  end

  it 'only caches GET requests by default' do
    expect(Rails.cache).not_to receive(:write)
    LHC.post(:local)
    assert_requested stub, times: 1
  end

  it 'also caches other methods, when explicitly enabled' do
    expect(Rails.cache).to receive(:write)
      .with(
        "lhc_cache-v1-post-http-local-ch",
        {
          body: 'The Website',
          code: 200,
          headers: nil,
          return_code: nil,
          mock: :webmock
        }, { expires_in: 5.minutes }
      )
      .and_call_original
    original_response = LHC.post(:local, cache_methods: [:post])
    cached_response = LHC.post(:local, cache_methods: [:post])
    expect(original_response.body).to eq cached_response.body
    expect(original_response.code).to eq cached_response.code
    expect(original_response.headers).to eq cached_response.headers
    assert_requested stub, times: 1
  end
end
