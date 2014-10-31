require 'rails_helper'

describe LHC do

  context 'default interceptors' do

    it 'should always return a list for default interceptors' do
      expect(LHC.default_interceptors).to eq []
    end
  end
end
