# frozen_string_literal: true

require 'rails_helper'

describe LHC::Caching do
  let(:redis_url) { 'redis://localhost:6379/0' }
  let(:redis_cache) do
    spy('ActiveSupport::Cache::RedisCacheStore')
  end

  before do
    Rails.cache.clear
    LHC.config.interceptors = [LHC::Caching]
    ActiveSupport::Cache::RedisCacheStore.new(url: redis_url).clear
    allow(ActiveSupport::Cache::RedisCacheStore).to receive(:new).and_return(redis_cache)
    allow(redis_cache).to receive(:present?).and_return(true)
  end

  let!(:request_stub) do
    stub_request(:get, "http://local.ch/")
      .to_return(body: '<h1>Hi there</h1>')
  end

  def request
    LHC.get('http://local.ch', cache: true)
  end

  def response_has_been_cached_and_served_from_cache!
    original_response = request
    cached_response = request

    expect(original_response.body).to eq cached_response.body
    expect(original_response.code).to eq cached_response.code
    expect(original_response.headers).to eq cached_response.headers
    expect(original_response.options[:return_code]).to eq cached_response.options[:return_code]
    expect(original_response.mock).to eq cached_response.mock

    assert_requested request_stub, times: 1
  end

  context 'only local cache has been configured' do
    before do
      LHC::Caching.cache = Rails.cache
    end

    it 'serves a response from local cache without trying the central cache' do
      expect(Rails.cache).to receive(:fetch).at_least(:once).and_call_original
      expect(Rails.cache).to receive(:write).and_call_original
      expect(-> { response_has_been_cached_and_served_from_cache! })
        .to output(%Q{[LHC] served from local cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
    end
  end

  context 'local and central cache have been configured' do
    before do
      LHC::Caching.cache = Rails.cache
      LHC::Caching.central = {
        read: redis_url,
        write: redis_url
      }
    end

    context 'found in central cache' do
      it 'serves it from central cache if found there' do
        expect(redis_cache).to receive(:fetch).and_return(nil, body: '<h1>Hi there</h1>', code: 200, headers: nil, return_code: nil, mock: :webmock)
        expect(redis_cache).to receive(:write).and_return(true)
        expect(Rails.cache).to receive(:fetch).and_call_original
        expect(Rails.cache).to receive(:write).and_call_original
        expect(-> { response_has_been_cached_and_served_from_cache! })
          .to output(%Q{[LHC] served from central cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
      end
    end

    context 'not found in central cache' do
      it 'serves it from local cache if found there' do
        expect(redis_cache).to receive(:fetch).and_return(nil, nil)
        expect(redis_cache).to receive(:write).and_return(true)
        expect(Rails.cache).to receive(:fetch).at_least(:once).and_call_original
        expect(Rails.cache).to receive(:write).and_call_original
        expect(-> { response_has_been_cached_and_served_from_cache! })
          .to output(%Q{[LHC] served from local cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
      end
    end
  end

  context 'only central read configured' do
    before do
      LHC::Caching.cache = Rails.cache
      LHC::Caching.central = {
        read: redis_url
      }
    end

    it 'still serves responses from cache, but does not write them back' do
      expect(redis_cache).to receive(:fetch).and_return(nil, body: '<h1>Hi there</h1>', code: 200, headers: nil, return_code: nil, mock: :webmock)
      expect(redis_cache).not_to receive(:write)
      expect(Rails.cache).to receive(:fetch).and_call_original
      expect(Rails.cache).to receive(:write).and_call_original
      expect(-> { response_has_been_cached_and_served_from_cache! })
        .to output(%Q{[LHC] served from central cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
    end
  end

  context 'only central write configured' do
    before do
      LHC::Caching.cache = Rails.cache
      LHC::Caching.central = {
        write: redis_url
      }
    end

    it 'still writes responses to cache, but does not retrieve them from there' do
      expect(redis_cache).not_to receive(:fetch)
      expect(redis_cache).to receive(:write).and_return(true)
      expect(Rails.cache).to receive(:fetch).at_least(:once).and_call_original
      expect(Rails.cache).to receive(:write).and_call_original
      expect(-> { response_has_been_cached_and_served_from_cache! })
        .to output(%Q{[LHC] served from local cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
    end
  end

  context 'central cache configured only' do
    before do
      LHC::Caching.cache = nil
      LHC::Caching.central = {
        read: redis_url,
        write: redis_url
      }
    end

    it 'does not inquire the local cache for information neither to write them' do
      expect(redis_cache).to receive(:fetch).and_return(nil, body: '<h1>Hi there</h1>', code: 200, headers: nil, return_code: nil, mock: :webmock)
      expect(redis_cache).to receive(:write).and_return(true)
      expect(-> { response_has_been_cached_and_served_from_cache! })
        .to output(%Q{[LHC] served from central cache: "LHC_CACHE(v1): GET http://local.ch"\n}).to_stdout
    end
  end
end
