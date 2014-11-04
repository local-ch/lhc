require 'rails_helper'

describe LHC::Endpoint do

  context 'placeholders' do

    it 'returns all placeholders alphabetically sorted' do
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      expect(
        endpoint.placeholders
      ).to eq [':campaign_id', ':datastore']
    end
  end
end
