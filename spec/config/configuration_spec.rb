require 'rails_helper'

describe LHC do

  context 'configuration' do

    it 'configures urls to be able to access them by name later' do
      endpoint = 'http://analytics.lb-service/track/:entity_id/w/:type'
      parameters = { env: 'PROD' }
      LHC::Config.set(:kpi_tracker,
        endpoint: endpoint,
        parameters: parameters
      )
      expect(LHC::Config[:kpi_tracker][:endpoint]).to eq endpoint
      expect(LHC::Config[:kpi_tracker][:parameters]).to eq parameters
    end
  end
end
