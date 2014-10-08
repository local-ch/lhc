require 'rails_helper'

describe LHC do

  context 'post' do

    let(:feedback) do
      {
        recommended: true,
        source_id: 'aaa',
        content_ad_id: '1z-5r1fkaj'
      }
    end

    before(:each) do
      stub_request(:post, "http://datastore.lb-service/v2/feedbacks")
      .with(body: feedback)
      .to_return(status: 200, body: feedback.to_json, headers: {'Content-Encoding' => 'UTF-8'})
    end

    it 'does a post request when providing a complete url' do
      LHC.post('http://datastore.lb-service/v2/feedbacks', body: feedback)
    end

    # it 'does a get request when providing a configured name of an endpoint' do
    #   endpoint = 'http://:datastore/v2/feedbacks'
    #   params = { datastore: 'datastore.lb-service' }
    #   LHC::Config.set(:feedbacks, endpoint, params)
    #   LHC.get(:feedbacks, parameters)
    # end

    # it 'it makes response data available in a rails way' do
    #   response = LHC.get('http://datastore.lb-service/v2/feedbacks', parameters)
    #   expect(response.data.total).to eq 99
    # end
    #
    # it 'provides response headers' do
    #   response = LHC.get('http://datastore.lb-service/v2/feedbacks', parameters)
    #   expect(response.headers).to be
    # end
  end
end
