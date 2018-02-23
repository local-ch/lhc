require 'spec_helper'

describe LHC do
  context 'request' do
    before { stub_request(:get, "http://datastore/v2/feedbacks").to_return(status: 200, body: "{}") }
    it "is able to call .request without LHC raising NoMethodError: undefined method `blank?' for nil:NilClass when calling it outside of the rails context" do
      expect { LHC.request(url: "http://datastore/v2/feedbacks", method: :get) }.not_to raise_error
    end
  end
end
