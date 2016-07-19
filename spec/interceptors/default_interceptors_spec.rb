require 'rails_helper'

describe LHC do
  context 'default interceptors' do
    before(:each) do
      LHC.configure {}
    end

    it 'alwayses return a list for default interceptors' do
      expect(LHC.config.interceptors).to eq []
    end
  end
end
