require 'rails_helper'

describe LHC::Endpoint do

  context 'injections' do

    it 'returns all possible injections alphabetically sorted' do
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      expect(
        endpoint.injections
      ).to eq [':campaign_id', ':datastore']
    end
  end
end
