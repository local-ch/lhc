require 'rails_helper'

describe LHC::Caching do
  context 'parameters' do
    before(:each) do
      LHC.config.interceptors = [LHC::Caching]
      Rails.cache.clear
    end

    it 'considers parameters when writing/reading from cache' do
      LHC.config.endpoint(:local, 'http://local.ch', cache: true)
      stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website')
      stub_request(:get, 'http://local.ch?location=zuerich').to_return(status: 200, body: 'The Website for Zuerich')
      expect(
        LHC.get(:local).body
      ).to eq 'The Website'
      expect(
        LHC.get(:local, params: { location: 'zuerich' }).body
      ).to eq 'The Website for Zuerich'
    end
  end
end
