require 'rails_helper'

describe LHC::Request do

  it 'injects params into url patterns when using configured endpoints' do
    options = { params: {
      datastore: 'http://datastore-stg.lb-service/v2'
    }}
    LHC.set(:find_feedback, ':datastore/feedbacks/:id', options)
    stub_request(:get, 'http://datastore-stg.lb-service/v2/feedbacks/123')
    LHC.get(:find_feedback, params:{id: 123})
  end

  it 'injects params into url patterns when doing an explicit request' do
    stub_request(:get, 'http://datastore-stg.lb-service:8080/v2/feedbacks/123')
    LHC.get('http://datastore-stg.lb-service:8080/v2/feedbacks/:id', params:{id: 123})
  end
end
