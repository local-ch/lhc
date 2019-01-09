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
        expect { { valid: valid, invalid: invalid }.to_s }.not_to raise_error
      end

      it 'to_json on a hash does raise an error' do
        expect { { valid: valid, invalid: invalid }.to_json }.to raise_error Encoding::UndefinedConversionError
      end
    end

    it 'invalid body, valid message' do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 200, body: "{ text : '#{invalid}' }")
      response = LHC.get('http://local.ch')
      expect { LHC::Error.new(valid, response).to_s }.not_to raise_error # Encoding::CompatibilityError
    end

    it 'valid body, invalid message' do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 200, body: "{ text : '#{valid}' }")
      response = LHC.get('http://local.ch')
      expect { LHC::Error.new(invalid, response).to_s }.not_to raise_error # Encoding::CompatibilityError
    end
    # the other cases cannot be tested (for example what happens if the headers contain invalid data)
    # because the mocking framework triggers the encoding error already

    context 'some mocked response' do
      let(:request) do
        double('request',
               method: 'GET',
               url: 'http://example.com/sessions',
               headers: { 'Bearer Token' => "aaaaaaaa-bbbb-cccc-dddd-eeee" },
               options: { followlocation: true,
                          auth: { bearer: "aaaaaaaa-bbbb-cccc-dddd-eeee" },
                          params: { limit: 20 }, url: "http://example.com/sessions" })
      end

      let(:response) do
        double('response',
               request: request,
               code: 500,
               options: { return_code: :internal_error, response_headers: "" },
               body: '{"status":500,"message":"undefined"}')
      end

      subject { LHC::Error.new('The error message', response) }

      it 'produces correct debug output' do
        expect(subject.to_s.split("\n")).to eq(<<-MSG.strip_heredoc.split("\n"))
          GET http://example.com/sessions
          Options: {:followlocation=>true, :auth=>{:bearer=>"aaaaaaaa-bbbb-cccc-dddd-eeee"}, :params=>{:limit=>20}, :url=>"http://example.com/sessions"}
          Headers: {"Bearer Token"=>"aaaaaaaa-bbbb-cccc-dddd-eeee"}
          Response Code: 500 (internal_error)
          Response Options: {:return_code=>:internal_error, :response_headers=>""}
          {"status":500,"message":"undefined"}
          The error message
        MSG
      end
    end
  end
end
