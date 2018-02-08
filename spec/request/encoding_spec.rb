require 'rails_helper'

describe LHC::Request do
  context 'encoding url' do
    let(:url) { 'http://local.ch/something with spaces' }

    it 'can request urls with spaces inside' do
      stub_request(:get, URI.encode(url))
      LHC.get(url)
    end
  end

  context 'encoding params' do
    let(:url) { 'http://local.ch/api/search?name=:name' }

    it 'can do requests with params including spaces' do
      stub_request(:get, 'http://local.ch/api/search?name=My%20name%20is%20rabbit')
      LHC.get(url, params: { name: 'My name is rabbit' })
    end
  end

  context 'skip encoding' do
    let(:url) { 'http://local.ch/api/search?names[]=seba&names[]=david' }

    it 'does not encode if encoding is skipped' do
      stub_request(:get, 'http://local.ch/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid')
      LHC.get('http://local.ch/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid', url_encoding: false)
    end

    it 'does double encoding, if you really want to' do
      stub_request(:get, 'http://local.ch/api/search?names%255B%255D%253Dseba%2526names%255B%255D%253Ddavid')
      LHC.get('http://local.ch/api/search?names%5B%5D%3Dseba%26names%5B%5D%3Ddavid')
    end
  end
end
