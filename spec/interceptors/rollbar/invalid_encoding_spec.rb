# frozen_string_literal: true

require 'rails_helper'

describe LHC::Rollbar do
  context 'invalid encoding in rollbar payload' do
    before(:each) do
      LHC.config.interceptors = [LHC::Rollbar]
      stub_request(:get, 'http://local.ch').to_return(status: 400)

      allow(described_class).to receive(:fix_invalid_encoding).and_call_original
      # a stub that will throw a error on first call and suceed on subsequent calls
      call_counter = 0
      class Rollbar; end
      ::Rollbar.stub(:warning) do
        call_counter += 1
        raise Encoding::UndefinedConversionError if call_counter == 1
      end
    end


    let(:invalid) { (+"in\xc3lid").force_encoding('ASCII-8BIT') }
    let(:valid) { described_class.fix_invalid_encoding(invalid) }

    before(:each) do
      # the response for the caller is still LHC::BadRequest
      expect(-> { LHC.get('http://local.ch', rollbar: { additional: invalid }) }).to raise_error LHC::BadRequest
    end

    it 'calls fix_invalid_encoding incase a Encoding::UndefinedConversionError was encountered' do
      expect(described_class).to have_received(:fix_invalid_encoding).with(invalid)
    end

    it 'calls Rollbar.warn with the fixed data' do
      expect(::Rollbar).to have_received(:warning)
        .with(
          'Status: 400 URL: http://local.ch',
          hash_including(
            response: anything,
            request: anything,
            additional: valid
          )
        )
    end
  end
end
