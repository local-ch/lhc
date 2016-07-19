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
      stub_request(:post, "http://datastore/v2/feedbacks")
        .with(body: feedback.to_json)
        .to_return(status: 200, body: feedback.to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a post request when providing a complete url' do
      LHC.post('http://datastore/v2/feedbacks', body: feedback.to_json)
    end

    it 'does a post request when providing the name of a configured endpoint' do
      url = 'http://:datastore/v2/feedbacks'
      options = { params: { datastore: 'datastore' } }
      LHC.configure { |c| c.endpoint(:feedbacks, url, options) }
      LHC.post(:feedbacks, body: feedback.to_json)
    end

    it 'it makes response data available in a rails way' do
      response = LHC.post('http://datastore/v2/feedbacks', body: feedback.to_json)
      expect(response.data.source_id).to eq 'aaa'
    end

    it 'provides response headers' do
      response = LHC.post('http://datastore/v2/feedbacks', body: feedback.to_json)
      expect(response.headers).to be
    end
  end
end
