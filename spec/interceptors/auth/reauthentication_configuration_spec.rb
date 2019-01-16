# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  let(:bearer_token) { '123456' }

  before(:each) do
    stub_request(:get, 'http://local.ch').with(headers: { 'Authorization' => "Bearer #{bearer_token}" })
  end

  context "configuration check not happening" do
    let(:options) { { bearer: bearer_token } }

    before(:each) { LHC.config.interceptors = [LHC::Auth, LHC::Retry] }

    it "max_recovery_attempts is zero" do
      expect_any_instance_of(described_class).not_to receive(:warn)
      LHC.config.endpoint(:local, 'http://local.ch', auth: options.merge(max_recovery_attempts: 0))
      LHC.get(:local)
    end

    it "max_recovery_attempts is missing" do
      expect_any_instance_of(described_class).not_to receive(:warn)
      LHC.config.endpoint(:local, 'http://local.ch', auth: options)
      LHC.get(:local)
    end
  end

  context "configuration check happening" do
    let(:options) { { bearer: bearer_token, max_recovery_attempts: 1, refresh_client_token: -> { "here comes your refresh code" } } }

    it "no warning with proper options" do
      LHC.config.interceptors = [LHC::Auth, LHC::Retry]
      LHC.config.endpoint(:local, 'http://local.ch', auth: options)
      expect_any_instance_of(described_class).not_to receive(:warn)
      LHC.get(:local)
    end

    it "warn refresh_client_token is a string" do
      LHC.config.interceptors = [LHC::Auth, LHC::Retry]
      LHC.config.endpoint(:local, 'http://local.ch', auth: options.merge(refresh_client_token: bearer_token))
      expect_any_instance_of(described_class).to receive(:warn).with("[WARNING] The given refresh_client_token must be a Proc for reauthentication.")
      LHC.get(:local)
    end

    it "warn interceptors miss LHC::Retry" do
      LHC.config.interceptors = [LHC::Auth]
      LHC.config.endpoint(:local, 'http://local.ch', auth: options)
      expect_any_instance_of(described_class).to receive(:warn).with("[WARNING] Your interceptors must include LHC::Retry after LHC::Auth.")
      LHC.get(:local)
    end

    it "warn interceptors LHC::Retry before LHC::Auth" do
      LHC.config.interceptors = [LHC::Retry, LHC::Auth]
      LHC.config.endpoint(:local, 'http://local.ch', auth: options)
      expect_any_instance_of(described_class).to receive(:warn).with("[WARNING] Your interceptors must include LHC::Retry after LHC::Auth.")
      LHC.get(:local)
    end
  end
end
