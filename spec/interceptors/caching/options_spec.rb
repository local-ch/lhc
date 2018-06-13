require 'rails_helper'

# due to the fact that options passed into LHC get dup'ed
# we need a class where we can setup method expectations
# with `expect_any_instance`
class CacheMock
  def fetch(*_); end

  def write(*_); end
end

describe LHC::Caching do
  let(:default_cache) { LHC::Caching.cache }

  before(:each) do
    stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website')
    LHC.config.interceptors = [LHC::Caching]
    default_cache.clear
  end

  it 'maps deprecated cache options' do
    expected_options = { expires_in: 5.minutes, race_condition_ttl: 15.seconds }
    expected_key = "LHC_CACHE(v1): key"
    expect(default_cache).to receive(:write).with(expected_key, anything, expected_options)
    expect(lambda {
      LHC.get('http://local.ch', cache: true, cache_expires_in: 5.minutes, cache_key: 'key', cache_race_condition_ttl: 15.seconds)
    }).to output(
      /Cache options have changed! cache_expires_in, cache_key, cache_race_condition_ttl are deprecated and will be removed in future versions./
    ).to_stderr
  end

  it 'does cache' do
    expect(default_cache).to receive(:fetch)
    expect(default_cache).to receive(:write)
    LHC.get('http://local.ch', cache: true)
  end

  it 'does not cache' do
    expect(default_cache).not_to receive(:fetch)
    expect(default_cache).not_to receive(:write)
    LHC.get('http://local.ch')
  end

  context 'options - directly via LHC.get' do
    it 'uses the default cache' do
      expect(default_cache).to receive(:fetch)
      expect(default_cache).to receive(:write)
      LHC.get('http://local.ch', cache: true)
    end

    it 'uses the provided cache' do
      expect_any_instance_of(CacheMock).to receive(:fetch)
      expect_any_instance_of(CacheMock).to receive(:write)
      LHC.get('http://local.ch', cache: { use: CacheMock.new })
    end

    it 'cache options are properly forwarded to the cache' do
      cache_options = { expires_in: 5.minutes, race_condition_ttl: 15.seconds }
      expect(default_cache).to receive(:write).with(anything, anything, cache_options)
      LHC.get('http://local.ch', cache: cache_options)
    end
  end

  context 'options - via endpoint configuration' do
    it 'uses the default cache' do
      LHC.config.endpoint(:local, 'http://local.ch', cache: true)
      expect(default_cache).to receive(:fetch)
      expect(default_cache).to receive(:write)
      LHC.get(:local)
    end

    it 'uses the provided cache' do
      options = { cache: { use: CacheMock.new } }
      LHC.config.endpoint(:local, 'http://local.ch', options)
      expect_any_instance_of(CacheMock).to receive(:fetch)
      expect_any_instance_of(CacheMock).to receive(:write)
      LHC.get(:local)
    end

    it 'cache options are properly forwarded to the cache' do
      cache_options = { expires_in: 5.minutes, race_condition_ttl: 15.seconds }
      LHC.config.endpoint(:local, 'http://local.ch', cache: cache_options)
      expect(default_cache).to receive(:write).with(anything, anything, cache_options)
      LHC.get(:local)
    end
  end
end
