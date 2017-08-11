require 'rails_helper'

describe LHC::Caching do
  before(:each) do
    LHC.config.interceptors = [LHC::Caching]
    LHC::Caching.default_cache = Rails.cache
    Rails.cache.clear
  end

  let!(:first_request) do
    stub_request(:get, "http://local.ch/").to_return(body: 'Website')
  end

  let!(:second_request) do
    stub_request(:get, "http://local.ch/weather").to_return(body: 'The weather')
  end

  it 'does not fetch requests served from cache when doing requests in parallel with hydra' do
    LHC.request([{ url: 'http://local.ch', cache: true }, { url: 'http://local.ch/weather', cache: true }])
    LHC.request([{ url: 'http://local.ch', cache: true }, { url: 'http://local.ch/weather', cache: true }])
    assert_requested first_request, times: 1
    assert_requested second_request, times: 1
  end
end
