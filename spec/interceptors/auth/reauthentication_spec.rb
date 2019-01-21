# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  let(:initial_token) { '123456' }
  let(:refresh_token) { 'abcdef' }
  let(:options) { { bearer: initial_token, refresh_client_token: -> { refresh_token } } }
  let!(:auth_failing) do
    stub_request(:get, 'http://local.ch')
      .with(headers: { 'Authorization' => "Bearer #{initial_token}" })
      .to_return(status: 401, body: "{}") # LHC::Unauthorized
  end
  let!(:auth_suceeding_after_recovery) do
    stub_request(:get, 'http://local.ch')
      .with(headers: { 'Authorization' => "Bearer #{refresh_token}" })
  end

  before(:each) do
    LHC.config.interceptors = [LHC::Auth, LHC::Retry]
  end

  it "recovery is attempted" do
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    # the retried request (with updated Bearer), that should work
    LHC.get(:local)
    expect(auth_suceeding_after_recovery).to have_been_made.once
  end

  it "recovery is not attempted again when the request has reauthenticated: true " do
    LHC.config.endpoint(:local, 'http://local.ch', auth: options.merge(reauthenticated: true))
    expect { LHC.get(:local) }.to raise_error(LHC::Unauthorized)
  end
end
