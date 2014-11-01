require 'rails_helper'

describe LHC do

  context 'configuration of injections' do

    it 'injects global configured injection values in url patterns' do
      LHC.config.injection(:datastore, 'http://datastore.lb-service/v2')
      stub_request(:get, "http://datastore.lb-service/v2/feedbacks")
      LHC.get(':datastore/feedbacks')
    end

    it 'raises in case of claching injection name' do
      LHC.config.injection(:datastore, 'http://datastore.lb-service')
      expect(->{
        LHC.config.injection(:datastore, 'http://datastore-stg.lb-service')
      }).to raise_error 'Injection already exists for that name'
    end
  end
end
