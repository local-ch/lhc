require 'rails_helper'

describe LHC::Request do

  it 'does not alter the options that where passed' do
    LHC.set(:kpi_tracker, 'http://analytics.lb-service/track/:entity_id/w', { params: { env: 'PROD' } })
    options = { params: { entity_id: '123' } }
    stub_request(:get, "http://analytics.lb-service/track/123/w?env=PROD")
    LHC.get(:kpi_tracker, options)
    expect(options).to eq({ params: { entity_id: '123' } })
  end
end
