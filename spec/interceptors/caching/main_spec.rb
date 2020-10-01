# frozen_string_literal: true

require 'rails_helper'

describe LHC::Caching do
  before(:each) do
    LHC.config.interceptors = [LHC::Caching]
    LHC::Caching.cache = Rails.cache
    Rails.cache.clear
  end

  let(:stub) { stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website') }

  it 'serves a response from cache' do
    stub
    LHC.config.endpoint(:local, 'http://local.ch', cache: { expires_in: 5.minutes })
    expect(Rails.cache).to receive(:write)
      .with(
        "LHC_CACHE(v#{LHC::Caching::CACHE_VERSION}): GET http://local.ch",
        {
          body: 'The Website',
          code: 200,
          headers: nil,
          return_code: nil,
          mock: :webmock
        }, { expires_in: 5.minutes }
      )
      .and_call_original
    original_response = LHC.get(:local)
    cached_response = LHC.get(:local)
    expect(original_response.body).to eq cached_response.body
    expect(original_response.code).to eq cached_response.code
    expect(original_response.headers).to eq cached_response.headers
    expect(original_response.options[:return_code]).to eq cached_response.options[:return_code]
    expect(original_response.mock).to eq cached_response.mock
    assert_requested stub, times: 1
  end

  it 'does not serve from cache if option is not set' do
    LHC.config.endpoint(:local, 'http://local.ch')
    expect(Rails.cache).not_to receive(:write)
    expect(Rails.cache).not_to receive(:fetch)
    stub
    2.times { LHC.get(:local) }
    assert_requested stub, times: 2
  end

  it 'lets you configure the cache key that will be used' do
    LHC.config.endpoint(:local, 'http://local.ch', cache: { key: 'STATICKEY' })
    expect(Rails.cache).to receive(:fetch).at_least(:once).with("LHC_CACHE(v#{LHC::Caching::CACHE_VERSION}): STATICKEY").and_call_original
    expect(Rails.cache).to receive(:write).with("LHC_CACHE(v#{LHC::Caching::CACHE_VERSION}): STATICKEY", anything, anything).and_call_original
    stub
    LHC.get(:local)
  end

  it 'does not store server errors in cache' do
    LHC.config.endpoint(:local, 'http://local.ch', cache: true)
    stub_request(:get, 'http://local.ch').to_return(status: 500, body: 'ERROR')
    expect { LHC.get(:local) }.to raise_error LHC::ServerError
    stub
    expect(Rails.cache).to receive(:write).once
    LHC.get(:local)
  end

  it 'marks response not from cache as not served from cache and from cache as served from cache' do
    stub
    LHC.config.endpoint(:local, 'http://local.ch', cache: true)
    original_response = LHC.get(:local)
    expect(original_response.from_cache?).to eq false
    cached_response = LHC.get(:local)
    expect(cached_response.from_cache?).to eq true
  end
end
