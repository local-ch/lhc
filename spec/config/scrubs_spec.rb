# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  context 'configuration of scrubs' do
    it 'has a default value for scrubs'  do
      expect(LHC.config.scrubs[:auth]).to eq [:bearer, :basic]
    end

    context 'when only bearer auth should get scrubbed' do
      before(:each) do
        LHC.configure do |c|
          c.scrubs = { auth: [:bearer] }
        end
      end

      it 'has only bearer auth in scrubs' do
        expect(LHC.config.scrubs[:auth]).to eq([:bearer])
      end
    end
  end

  context 'when nothing should be scrubbed' do
    before(:each) do
      LHC.configure do |c|
        c.scrubs = {}
      end
    end

    it 'does not have scrubs' do
      expect(LHC.config.scrubs.blank?).to be true
      expect(LHC.config.scrubs[:auth]).to be nil 
    end
  end

  # TODO test also body attributes
end
