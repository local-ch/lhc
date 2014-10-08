require 'rails_helper'

describe LHC do

  context 'get' do

    before(:each) do
      stub_request(:get, "http://datastore.lb-service/v2/feedbacks?has_reviews=true")
      .to_return(status: 200, body: { total: 99 }.to_json, headers: {'Content-Encoding' => 'UTF-8'})
    end

    let(:parameters) do
      { has_reviews: true }
    end

    it 'does a get request when providing a complete url' do
      LHC.get('http://datastore.lb-service/v2/feedbacks', params: parameters)
    end

    it 'does a get request when providing a configured name of an endpoint' do
      endpoint = 'http://:datastore/v2/feedbacks'
      params = { datastore: 'datastore.lb-service' }
      LHC::Config.set(:feedbacks, endpoint, params)
      LHC.get(:feedbacks, params: parameters)
    end

    it 'it makes response data available in a rails way' do
      response = LHC.get('http://datastore.lb-service/v2/feedbacks', params: parameters)
      expect(response.data.total).to eq 99
    end

    it 'provides response headers' do
      response = LHC.get('http://datastore.lb-service/v2/feedbacks', params: parameters)
      expect(response.headers).to be
    end
  end
end
