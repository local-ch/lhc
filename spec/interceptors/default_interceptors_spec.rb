require 'rails_helper'

describe LHC do
  context 'default interceptors' do
    before(:each) do
      described_class.configure {}
    end

    it 'alwayses return a list for default interceptors' do
      expect(described_class.config.interceptors).to eq []
    end
  end
end
