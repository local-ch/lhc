require 'rails_helper'

describe LHC::Endpoint do
  context 'placeholders' do
    it 'returns all placeholders alphabetically sorted' do
      endpoint = LHC::Endpoint.new('{+datastore}/v2/{campaign_id}/feedbacks')
      expect(
        endpoint.placeholders
      ).to eq [:campaign_id, :datastore]
    end

    it 'allows basic auth token in url, like used on github' do
      stub_request(:get, "https://d123token:@api.github.com/search")
        .to_return(body: {}.to_json)
      expect(->{
        LHC.get("https://d123token:@api.github.com/search")
      }).not_to raise_error
    end

    it 'allows complete basic auth (username password) in url, like used for the gemserer' do
      stub_request(:get, "https://name:password@gemserver.com")
        .to_return(body: {}.to_json)
      expect(->{
        LHC.get("https://name:password@gemserver.com")
      }).not_to raise_error
    end
  end
end
