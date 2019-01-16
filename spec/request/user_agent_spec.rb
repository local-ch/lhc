# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  before do
    LHC.send(:remove_const, :Request)
    load('lhc/concerns/lhc/request/user_agent_concern.rb')
    load('lhc/request.rb')
  end

  context 'default headers' do
    context 'agent' do
      it 'sets header agent information to be LHC' do
        stub_request(:get, "http://local.ch/")
          .with(
            headers: {
              'User-Agent' => "LHC (#{LHC::VERSION}; Dummy) [https://github.com/local-ch/lhc]"
            }
          )
          .to_return(status: 200)
        LHC.get('http://local.ch')
      end
    end
  end
end
