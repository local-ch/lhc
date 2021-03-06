# frozen_string_literal: true

require 'rails_helper'

describe LHC::Response do
  context 'effective_url' do
    let(:effective_url) { 'https://www.local.ch' }

    let(:raw_response) { OpenStruct.new(effective_url: effective_url) }

    it 'provides effective_url' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.effective_url).to eq effective_url
    end
  end
end
