require 'rails_helper'

describe LHC::Request do

  it 'compiles url in case of configured endpoints' do
    options = { params: {
      has_reviews: true
    }}
    url = 'http://datastore-stg.lb-service/v2/campaign/:campaign_id/feedbacks'
    LHC.configure { |c| c.endpoint(:feedbacks, url, options) }
    stub_request(:get, 'http://datastore-stg.lb-service/v2/campaign/123/feedbacks?has_reviews=true')
    LHC.get(:feedbacks, params:{campaign_id: 123})
  end

  it 'compiles url when doing a request' do
    stub_request(:get, 'http://datastore-stg.lb-service:8080/v2/feedbacks/123')
    LHC.get('http://datastore-stg.lb-service:8080/v2/feedbacks/:id', params:{id: 123})
  end
end
