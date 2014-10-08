require 'rails_helper'

describe LHC::Endpoint do

  context 'remove injected params' do

    it 'removes injected params from hash and returns the removed params' do
      params = {
        datastore: 'http://datastore.lb-service',
        campaign_id: 'abc',
        has_reviews: true
      }
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      removed = endpoint.remove_injected_params!(params)
      expect(params).to eq ({ has_reviews: true })
      expect(removed).to eq(datastore: 'http://datastore.lb-service', campaign_id: 'abc')
    end
  end
end
