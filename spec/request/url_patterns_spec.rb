require 'rails_helper'

describe LHC::Request do

  it 'injects params into url patterns when using configured endpoints' do
    options = { params: {
      has_reviews: true
    }}
    url = 'http://datastore-stg.lb-service/v2/campaign/:campaign_id/feedbacks'
    LHC.config.endpoint(:feedbacks, url, options)
    stub_request(:get, 'http://datastore-stg.lb-service/v2/campaign/123/feedbacks?has_reviews=true')
    LHC.get(:feedbacks, params:{campaign_id: 123})
  end

  it 'injects params into url patterns when doing an explicit request' do
    stub_request(:get, 'http://datastore-stg.lb-service:8080/v2/feedbacks/123')
    LHC.get('http://datastore-stg.lb-service:8080/v2/feedbacks/:id', params:{id: 123})
  end
end
