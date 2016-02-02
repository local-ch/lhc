require 'rails_helper'

describe LHC do
  context 'configuration of placeholders' do
    it 'uses values for placeholders defined globally' do
      described_class.configure { |c| c.placeholder(:datastore, 'http://datastore/v2') }
      stub_request(:get, "http://datastore/v2/feedbacks")
      described_class.get(':datastore/feedbacks')
    end

    it 'uses explicit values first' do
      described_class.configure { |c| c.placeholder(:campaign_id, '123') }
      stub_request(:get, 'http://datastore/v2/campaign/456/feedbacks')
      url = 'http://datastore/v2/campaign/:campaign_id/feedbacks'
      described_class.get(url, params: { campaign_id: '456' })
    end

    it 'raises in case of claching placeholder name' do
      described_class.configure { |c| c.placeholder(:datastore, 'http://datastore') }
      expect(lambda {
        described_class.config.placeholder(:datastore, 'http://datastore')
      }).to raise_error 'Placeholder already exists for that name'
    end

    it 'enforces placeholder name to be a symbol' do
      described_class.configure { |c| c.placeholder('datatore', 'http://datastore') }
      expect(described_class.config.placeholders[:datatore]).to eq 'http://datastore'
    end
  end
end
