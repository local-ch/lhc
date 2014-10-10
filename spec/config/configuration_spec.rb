require 'rails_helper'

describe LHC do

  context 'configuration' do

    let(:endpoint) { 'http://analytics.lb-service/track/:entity_id/w/:type' }

    let(:options) do
      {
        params: { env: 'PROD' },
        followlocation: false
      }
    end

    before(:each) { LHC::Config.set(:kpi_tracker, endpoint, options) }

    it 'configures urls to be able to access them by name later' do
      expect(LHC::Config[:kpi_tracker].endpoint).to eq endpoint
      expect(LHC::Config[:kpi_tracker].options).to eq options
    end

    it 'creates the url by injecting endpoint params and use configured params and options' do
      stub_request(:get, 'http://analytics.lb-service/track/123/w/request?env=PROD')
      response = LHC.get(:kpi_tracker, params: { entity_id: 123, type: 'request' })
      expect(response.request_options[:followlocation]).to eq false
    end
  end
end
