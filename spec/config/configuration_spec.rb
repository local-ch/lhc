require 'rails_helper'

describe LHC do

  context 'configuration' do

    it 'configures urls to be able to access them by name later' do
      endpoint = 'http://analytics.lb-service/track/:entity_id/w/:type'
      params = { env: 'PROD' }
      LHC::Config.set(:kpi_tracker, endpoint, params)
      expect(LHC::Config[:kpi_tracker].endpoint).to eq endpoint
      expect(LHC::Config[:kpi_tracker].params).to eq params
    end
  end
end
