require 'spec_helper'

describe LHC do
  context 'request' do
    it "is able to call .request without LHC raising NoMethodError: undefined method `blank?' for nil:NilClass when calling it outside of the rails context" do
      expect{ LHC.request(url: "http://datastore/v2/feedbacks", method: :get) }.to_not raise_error(NoMethodError)
    end
  end
end
