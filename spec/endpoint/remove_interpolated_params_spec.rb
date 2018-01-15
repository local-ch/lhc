require 'rails_helper'

describe LHC::Endpoint do
  it 'removes params used for interpolation' do
    params = {
      datastore: 'http://datastore',
      campaign_id: 'abc',
      has_reviews: true
    }
    endpoint = LHC::Endpoint.new('{+datastore}/v2/{campaign_id}/feedbacks')
    removed = endpoint.remove_interpolated_params!(params)
    expect(params).to eq(has_reviews: true)
    expect(removed).to eq(datastore: 'http://datastore', campaign_id: 'abc')
  end
end
