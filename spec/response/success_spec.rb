require 'rails_helper'

describe LHC::Response do
  context 'success?' do
    let(:response_success) { described_class.new(Typhoeus::Response.new(response_code: 200, mock: true), nil) }
    let(:response_error) { described_class.new(Typhoeus::Response.new(response_code: 404, mock: true), nil) }

    it { expect(response_success.success?).to be_truthy }
    it { expect(response_error.success?).to be_falsy }
  end
end
