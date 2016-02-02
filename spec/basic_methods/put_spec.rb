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
      stub_request(:put, "http://datastore/v2/feedbacks")
        .with(body: change.to_json)
        .to_return(status: 200, body: feedback.merge(change).to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a post request when providing a complete url' do
      described_class.put('http://datastore/v2/feedbacks', body: change.to_json)
    end

    it 'does a post request when providing the name of a configured endpoint' do
      url = 'http://:datastore/v2/feedbacks'
      options = { params: { datastore: 'datastore' } }
      described_class.configure { |c| c.endpoint(:feedbacks, url, options) }
      described_class.put(:feedbacks, body: change.to_json)
    end

    it 'it makes response data available in a rails way' do
      response = described_class.put('http://datastore/v2/feedbacks', body: change.to_json)
      expect(response.data.recommended).to eq false
    end

    it 'provides response headers' do
      response = described_class.put('http://datastore/v2/feedbacks', body: change.to_json)
      expect(response.headers).to be
    end
  end
end
