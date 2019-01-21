# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  context 'ignoring LHC::NotFound' do
    let(:response) { LHC.get('http://local.ch', ignored_errors: [LHC::NotFound]) }

    before { stub_request(:get, 'http://local.ch').to_return(status: 404) }

    it 'does not raise an error' do
      expect { response }.not_to raise_error
    end

    it 'body is nil' do
      expect(response.body).to eq nil
    end

    it 'data is nil' do
      expect(response.data).to eq nil
    end

    it 'does raise an error for 500' do
      stub_request(:get, 'http://local.ch').to_return(status: 500)
      expect { response }.to raise_error LHC::InternalServerError
    end

    it 'provides the information if the error was ignored' do
      expect(response.error_ignored?).to eq true
      expect(response.request.error_ignored?).to eq true
    end
  end

  context 'inheritance when ignoring errors' do
    before { stub_request(:get, 'http://local.ch').to_return(status: 404) }

    it "does not raise an error when it's a subclass of the ignored error" do
      expect {
        LHC.get('http://local.ch', ignored_errors: [LHC::Error])
      }.not_to raise_error
    end

    it "does raise an error if it's not a subclass of the ignored error" do
      expect {
        LHC.get('http://local.ch', ignored_errors: [ArgumentError])
      }.to raise_error(LHC::NotFound)
    end
  end
end
