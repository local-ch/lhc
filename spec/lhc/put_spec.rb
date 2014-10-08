require 'rails_helper'

describe LHC do

  context 'post' do

    let(:feedback) do
      {
        recommended: false,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
    end

    let(:change) do
      {
        recommended: false
      }
    end

    before(:each) do
      stub_request(:put, "http://datastore.lb-service/v2/feedbacks")
      .with(body: change.to_json)
      .to_return(status: 200, body: feedback.merge(change).to_json, headers: {'Content-Encoding' => 'UTF-8'})
    end

    it 'does a post request when providing a complete url' do
      LHC.put('http://datastore.lb-service/v2/feedbacks', body: change.to_json)
    end

    it 'does a post request when providing the name of a configured endpoint' do
      endpoint = 'http://:datastore/v2/feedbacks'
      params = { datastore: 'datastore.lb-service' }
      LHC::Config.set(:feedbacks, endpoint, params)
      LHC.put(:feedbacks, body: change.to_json)
    end

    it 'it makes response data available in a rails way' do
      response = LHC.put('http://datastore.lb-service/v2/feedbacks', body: change.to_json)
      expect(response.data.recommended).to eq false
    end

    it 'provides response headers' do
      response = LHC.put('http://datastore.lb-service/v2/feedbacks', body: change.to_json)
      expect(response.headers).to be
    end
  end
end
