require 'rails_helper'

describe LHC::Response do

  context 'time' do

    let(:time) { 1.3 }

    it 'provides response time in milliseconds' do
      response = LHC::Response.new(
        OpenStruct.new({time: time})
      )
      expect(response.time).to eq time*1000
    end
  end
end
