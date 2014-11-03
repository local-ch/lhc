require 'rails_helper'

describe LHC do

  context 'configured endpoints' do

    let(:url) { 'http://analytics.lb-service/track/:entity_id/w/:type' }

    let(:options) do
      {
        params: { env: 'PROD' },
        followlocation: false
      }
    end

    before(:each) { LHC.config.endpoint(:kpi_tracker, url, options) }

    it 'configures urls to be able to access them by name later' do
      expect(LHC.config.endpoints[:kpi_tracker].url).to eq url
      expect(LHC.config.endpoints[:kpi_tracker].options).to eq options
    end

    it 'generates the url by injecting params' do
      stub_request(:get, 'http://analytics.lb-service/track/123/w/request?env=PROD')
      response = LHC.get(:kpi_tracker, params: { entity_id: 123, type: 'request' })
      expect(response.request.options[:followlocation]).to eq false
    end

    it 'gets overwritten by explicit request options' do
      stub_request(:get, 'http://analytics.lb-service/track/123/w/request?env=STG')
      response = LHC.get(:kpi_tracker, params: { entity_id: 123, type: 'request', env: 'STG' })
    end

    it 'raises in case of claching endpoint names' do
      expect(->{
        LHC.config.endpoint(:kpi_tracker, 'http://kpi-tracker.lb-service')
      }).to raise_error 'Endpoint already exists for that name'
    end

    it 'enforces endpoint name to be a symbol' do
      LHC.config.endpoint('datastore', 'http://datastore.lb-service')
      expect(LHC.config.endpoints[:datastore].url).to eq 'http://datastore.lb-service'
    end
  end
end
