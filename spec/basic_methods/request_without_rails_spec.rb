require 'spec_helper'

describe LHC do
  context 'GET' do
    before do
      stub_request(:get, "http://datastore/v2/feedbacks").to_return(status: 200, body: "{}")
    end
    it "is able to call .request without LHC raising NoMethodError: undefined method `blank?' for nil:NilClass when calling it outside of the rails context" do
      expect { LHC.request(url: "http://datastore/v2/feedbacks", method: :get) }.not_to raise_error
    end
  end

  context 'POST' do
    before do
      stub_request(:post, "http://datastore/v2/feedbacks").to_return(status: 200, body: "{}")
    end

    it "is able to call .request without LHC raising NoMethodError: undefined method `deep_symbolize_keys' for {}:Hash" do
      options = {
        url: "http://datastore/v2/feedbacks",
        method: :post,
        body: {},
        headers: { 'Content-Type' => 'application/json' }
      }
      expect { LHC.request(options) }.not_to raise_error
    end
  end
end
