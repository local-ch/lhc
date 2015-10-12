require 'rails_helper'

describe LHC::Request do

  context 'encoding url' do

    let(:url) { 'http://local.ch/something with spaces' }

    it 'can request urls with spaces inside' do
      stub_request(:get, URI::encode(url))
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
end
