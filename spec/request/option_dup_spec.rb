require 'rails_helper'

describe LHC::Request do
  it 'does not alter the options that where passed' do
    LHC.configure { |c| c.endpoint(:kpi_tracker, 'http://analytics/track/{entity_id}/w', params: { env: 'PROD' }) }
    options = { params: { entity_id: '123' } }
    stub_request(:get, "http://analytics/track/123/w?env=PROD")
    LHC.get(:kpi_tracker, options)
    expect(options).to eq(params: { entity_id: '123' })
  end
end
