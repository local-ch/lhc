require 'rails_helper'

describe LHC::Error do

  context 'response' do

    it 'throws timeout exception in case of a timeout' do
      stub_request(:any, 'local.ch').to_return(status: 403)
      begin
        LHC.get('local.ch')
      rescue => e
        expect(e.response).to be_kind_of(LHC::Response)
        expect(e.response.code).to eq 403
      end
    end
  end
end
