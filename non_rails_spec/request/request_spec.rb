require 'spec_helper'

describe LHC::Request do
  before do
    allow_any_instance_of(LHC::Request).to receive(:use_configured_endpoint!)
    allow_any_instance_of(LHC::Request).to receive(:generate_url_from_template!)
  end
  context 'request without rails' do
    it 'does have deep_merge dependency met' do
      expect { described_class.new({}, false) }.to_not raise_error
    end
  end
end
