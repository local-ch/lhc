# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  # TODO write into readme that you need to also write down the default when you voerwrite the config
  it 'has a default value for scrubs' do
    expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
    expect(LHC.config.scrubs[:params]).to eq []
    expect(LHC.config.scrubs[:headers]).to eq []
    expect(LHC.config.scrubs[:body]).to eq ['password', 'password_confirmation']
  end

  describe 'auth' do
    context 'when only bearer auth should get scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs[:auth] = [:bearer]
        end
      end

      it 'has only bearer auth in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq([:bearer])
        expect(LHC.config.scrubs[:params]).to eq []
        expect(LHC.config.scrubs[:headers]).to eq []
        expect(LHC.config.scrubs[:body]).to eq ['password', 'password_confirmation']
      end
    end
  end

  context 'params' do
    context 'when additional param "api_key" should be scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs[:params] << 'api_key'
        end
      end

      it 'has "api_key" in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
        expect(LHC.config.scrubs[:params]).to eq ['api_key']
        expect(LHC.config.scrubs[:headers]).to eq []
        expect(LHC.config.scrubs[:body]).to eq ['password', 'password_confirmation']
      end
    end
  end

  context 'headers' do
    context 'when additional header "private_key" should be scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs[:headers] << 'private_key'
        end
      end

      it 'has "private_key" in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
        expect(LHC.config.scrubs[:params]).to eq []
        expect(LHC.config.scrubs[:headers]).to eq ['private_key']
        expect(LHC.config.scrubs[:body]).to eq ['password', 'password_confirmation']
      end
    end
  end

  context 'body' do
    context 'when only password should get scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs[:body] = ['password']
        end
      end

      it 'has password in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
        expect(LHC.config.scrubs[:params]).to eq []
        expect(LHC.config.scrubs[:headers]).to eq []
        expect(LHC.config.scrubs[:body]).to eq(['password'])
      end
    end

    context 'when "user_token" should be scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs[:body] << 'user_token'
        end
      end

      it 'has user_token in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
        expect(LHC.config.scrubs[:params]).to eq []
        expect(LHC.config.scrubs[:headers]).to eq []
        expect(LHC.config.scrubs[:body]).to eq(['password', 'password_confirmation', 'user_token'])
      end
    end
  end

  context 'when nothing should be scrubbed' do
    before(:each) do
      LHC.configure do |c|
        c.scrubs = {}
      end
    end

    it 'does not have scrubs' do
      expect(LHC.config.scrubs.blank?).to be true
      expect(LHC.config.scrubs[:auth]).to be nil
    end
  end
end
