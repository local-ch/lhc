# frozen_string_literal: true

require 'spec_helper'

describe LHC::Request do
  before do
    Object.send(:remove_const, :Rails)
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
              'User-Agent' => "LHC (#{LHC::VERSION}) [https://github.com/local-ch/lhc]"
            }
          )
          .to_return(status: 200)
        LHC.get('http://local.ch')
      end
    end
  end
end
