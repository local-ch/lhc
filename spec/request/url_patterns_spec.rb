require 'rails_helper'

describe LHC::Request do
  it 'compiles url in case of configured endpoints' do
    options = { params: {
      has_reviews: true
    } }
    url = 'http://datastore/v2/campaign/{campaign_id}/feedbacks'
    LHC.configure { |c| c.endpoint(:feedbacks, url, options) }
    stub_request(:get, 'http://datastore/v2/campaign/123/feedbacks?has_reviews=true')
    LHC.get(:feedbacks, params: { campaign_id: 123 })
  end

  it 'compiles url when doing a request' do
    stub_request(:get, 'http://datastore:8080/v2/feedbacks/123')
    LHC.get('http://datastore:8080/v2/feedbacks/{id}', params: { id: 123 })
  end

  it 'considers body when compiling urls' do
    stub_request(:post, "http://datastore:8080/v2/places/123")
    LHC.json.post('http://datastore:8080/v2/places/{id}', body: { id: 123 })
  end

  context 'custom data structures that respond to as_json (like LHS data or record)' do
    before do
      class CustomStructure

        def initialize(data)
          @data = data
        end

        def as_json
          @data.as_json
        end

        def to_json
          as_json.to_json
        end
      end
    end

    let(:data) do
      CustomStructure.new(id: '12345')
    end

    it 'compiles url from body params when body object respond_to(:as_json)' do
      stub_request(:post, "http://datastore/places/12345")
        .to_return(status: 200)
      LHC.post('http://datastore/places/{id}', body: data)
    end
  end
end
