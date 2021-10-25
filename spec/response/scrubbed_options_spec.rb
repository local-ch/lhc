# frozen_string_literal: true

require 'rails_helper'

describe LHC::Response do
  let(:options) do
    { effective_url: 'http://local.ch?api_key=api-key' }
  end

  let(:raw_response) { OpenStruct.new(options: options) }

  before do
    LHC.config.scrubs[:params] << 'api_key'
  end

  it 'provides headers' do
    response = LHC::Response.new(raw_response, nil)
    expect(response.scrubbed_options[:effective_url]).to eq "http://local.ch?api_key=#{LHC::Scrubber::SCRUB_DISPLAY}"
  end
end
