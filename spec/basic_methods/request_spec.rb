require 'rails_helper'

describe LHC do
  context 'request' do
    let(:total) { 99 }

    before(:each) do
      stub_request(:get, "http://datastore/v2/feedbacks?has_reviews=true")
        .to_return(status: 200, body: { total: total }.to_json, headers: { 'Content-Encoding' => 'UTF-8' })
    end

    it 'does a request returning a response' do
      response = LHC.request(url: 'http://datastore/v2/feedbacks', params: { has_reviews: true }, method: :get)
      expect(response.data.total).to eq total
    end
  end
end
