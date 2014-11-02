require 'rails_helper'

describe LHC::Error do

  context 'timeout' do

    it 'throws timeout exception in case of a timeout' do
      stub_request(:any, 'local.ch').to_timeout
      expect(->{
        LHC.get('local.ch')
      }).to raise_error LHC::Timeout
    end
  end
end
