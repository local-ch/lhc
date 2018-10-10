require 'spec_helper'

describe LHC::Request do
  context 'default headers' do
    context 'agent' do
      it 'sets header agent information to be LHC' do
        stub_request(:get, "http://local.ch/")
          .with(
            headers: {
              'User-Agent' => "LHC (#{LHC::VERSION}) [https://github.com/local-ch/lhc]"
            }
          )
          .to_return(status: 200)
        LHC.get('http://local.ch')
      end
    end
  end
end
