require 'rails_helper'

describe LHC::Error do
  context 'to_s' do
    let(:invalid) { "in\xc3lid".force_encoding('ASCII-8BIT') }
    let(:valid) { "vælid" }

    context 'check assumptions' do
      it 'joining raises an error' do
        expect { [valid, invalid].join }.to raise_error Encoding::CompatibilityError
      end
      it 'interpolation raises an error' do
        expect { "#{valid} #{invalid}" }.to raise_error Encoding::CompatibilityError
      end
      it 'to_json on an array raises an error' do
        expect { [valid, invalid].to_json }.to raise_error Encoding::UndefinedConversionError
      end

      it 'to_s on a hash does not raise an error' do
        expect { { valid: valid, invalid: invalid }.to_s }.to_not raise_error
      end

      it 'to_json on a hash does raise an error' do
        expect { { valid: valid, invalid: invalid }.to_json }.to raise_error Encoding::UndefinedConversionError
      end
    end

    it 'invalid body, valid message' do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 200, body: "{ text : '#{invalid}' }")
      response = LHC.get('http://local.ch')
      expect { LHC::Error.new(valid, response).to_s }.to_not raise_error #Encoding::CompatibilityError
    end

    it 'valid body, invalid message' do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 200, body: "{ text : '#{valid}' }")
      response = LHC.get('http://local.ch')
      expect { LHC::Error.new(invalid, response).to_s }.to_not raise_error #Encoding::CompatibilityError
    end
    # the other cases cannot be tested (for example what happens if the headers contain invalid data)
    # because the mocking framework triggers the encoding error already
  end
end
