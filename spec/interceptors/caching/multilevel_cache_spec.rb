# frozen_string_literal: true

require 'rails_helper'

describe LHC::Caching do

  before do
    Rails.cache.clear
    LHC.config.interceptors = [LHC::Caching]
  end

  let!(:request_stub) do
    stub_request(:get, "http://local.ch/")
      .to_return(body: '<h1>Hi there</h1>')
  end

  def request
    LHC.get('http://local.ch', cache: true)
  end

  def request_was_cached_and_served_from_cache!
    original_response = request
    cached_response = request

    expect(original_response.body).to eq cached_response.body
    expect(original_response.code).to eq cached_response.code
    expect(original_response.headers).to eq cached_response.headers
    expect(original_response.options[:return_code]).to eq cached_response.options[:return_code]
    expect(original_response.mock).to eq cached_response.mock

    assert_requested request_stub, times: 1
  end

  context 'local cache configured only' do

    before do
      LHC::Caching.cache = Rails.cache
    end

    it 'serves a response from local cache without trying the central cache' do
      expect(Rails.cache).to receive(:fetch).at_least(:once).and_call_original
      expect(Rails.cache).to receive(:write).and_call_original
      request_was_cached_and_served_from_cache!
    end
  end

  context 'local and central cache configured' do
    before do
      LHC::Caching.cache = Rails.cache
      LHC::Caching.central = {
        read: 'redis://localhost:6379/0',
        write: 'redis://localhost:6379/0'
      }
    end

    context 'found in central cache' do
      it 'serves it from central cache if found there' do
        request_was_cached_and_served_from_cache!
      end
    end

    context 'not found in central cache' do
      it 'serves it from local cache if found there' do

      end
    end

  end

  context 'only central read configured' do
    it 'still serves responses from cache, but does not write them back' do
      pending
    end
  end

  context 'only central write configured' do
    it 'still writes responses to cache, but does not retrieve them from there' do
      pending
    end
  end

  context 'central cache configured only' do

    it 'does not inquire the local cache for information neither to write them' do
      pending
    end
  end
end
