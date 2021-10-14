# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  let(:initial_token) { '123456' }
  let(:refresh_token) { 'abcdef' }

  let(:options) do
    { bearer: -> { DummyAuthentication.access_token }, refresh_client_token: -> { DummyAuthentication.refresh_token } }
  end
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
    class DummyAuthentication

      def self.refresh_token
        # updates access_token
      end

      def self.access_token
        # this is used as bearer token
      end
    end

    # It does not matter what value this method returns it is not use by LHC.
    # That method needs just to make sure that the value of the access_token
    # is the new valid token
    allow(DummyAuthentication).to receive(:refresh_token).and_return(nil)

    allow(DummyAuthentication).to receive(:access_token).and_return(initial_token, refresh_token)
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

  context 'token format' do
    let(:initial_token) { 'BAsZ-98-ZZZ' }

    it 'refreshes tokens with various formats' do
      LHC.config.endpoint(:local, 'http://local.ch', auth: options)
      LHC.get(:local)
      expect(auth_suceeding_after_recovery).to have_been_made.once
    end
  end
end
