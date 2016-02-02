require 'rails_helper'

describe LHC::Response do
  context 'time' do
    let(:time) { 1.3 }

    let(:raw_response) { OpenStruct.new(time: time) }

    it 'provides response time in milliseconds' do
      response = described_class.new(raw_response, nil)
      expect(response.time).to eq time * 1000
    end
  end
end
