require 'rails_helper'

describe LHC::Endpoint do

  context 'inject' do

    it 'injects parameters directly' do
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      expect(
        endpoint.inject(datastore: 'http://datastore.lb-service', campaign_id: 'abc')
      ).to eq "http://datastore.lb-service/v2/abc/feedbacks"
    end

    it 'injects parameters using provided proc' do
      endpoint = LHC::Endpoint.new(':datastore/v2')
      config = { datastore: 'http://datastore.lb-service' }
      find_injection = ->(match){
        config[match.gsub(':', '').to_sym]
      }
      expect(
        endpoint.inject(find_injection)
      ).to eq "http://datastore.lb-service/v2"
    end
  end
end
