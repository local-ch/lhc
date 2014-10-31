require 'rails_helper'

describe LHC do

  context 'configuration' do

    it 'raises in case of claching configuration names' do
      LHC.set(:kpi_tracker, 'http://kpi.lb-service')
      expect(->{
        LHC.set(:kpi_tracker, 'http://kpi-tracker.lb-service')
      }).to raise_error 'Configuration already exists for that name'
    end
  end
end
