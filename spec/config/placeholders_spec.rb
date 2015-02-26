require 'rails_helper'

describe LHC do

  context 'configuration of placeholders' do

    it 'uses values for placeholders defined globally' do
      LHC.configure { |c| c.placeholder(:datastore, 'http://datastore.lb-service/v2') }
      stub_request(:get, "http://datastore.lb-service/v2/feedbacks")
      LHC.get(':datastore/feedbacks')
    end

    it 'uses explicit values first' do
      LHC.configure {|c| c.placeholder(:campaign_id, '123') }
      stub_request(:get, 'http://datastore-stg.lb-service/v2/campaign/456/feedbacks')
      url = 'http://datastore-stg.lb-service/v2/campaign/:campaign_id/feedbacks'
      LHC.get(url, params: { campaign_id: '456' })
    end

    it 'raises in case of claching placeholder name' do
      LHC.configure { |c| c.placeholder(:datastore, 'http://datastore.lb-service') }
      expect(->{
        LHC.config.placeholder(:datastore, 'http://datastore-stg.lb-service')
      }).to raise_error 'Placeholder already exists for that name'
    end

    it 'enforces placeholder name to be a symbol' do
      LHC.configure { |c| c.placeholder('datatore', 'http://datastore.lb-service') }
      expect(LHC.config.placeholders[:datatore]).to eq 'http://datastore.lb-service'
    end
  end
end
