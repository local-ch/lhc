# frozen_string_literal: true

require 'rails_helper'

describe LHC::Monitoring do
  let(:stub) do
    stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website')
  end

  module Statsd
    def self.count(_path, _value); end

    def self.timing(_path, _value); end
  end

  before(:each) do
    LHC::Monitoring.statsd = Statsd
    Rails.cache.clear
    allow(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.before_request', 1)
    allow(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.count', 1)
    allow(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.after_request', 1)
    allow(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.200', 1)
  end

  context 'interceptors configured correctly' do
    before do
      LHC.config.interceptors = [LHC::Caching, LHC::Monitoring]
    end

    context 'requesting with cache option' do
      it 'monitors miss/hit for caching' do
        stub
        expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.cache.miss', 1)
        expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.cache.hit', 1)
        LHC.get('http://local.ch', cache: true)
        LHC.get('http://local.ch', cache: true)
      end
    end

    context 'request uncached' do
      it 'requesting without cache option' do
        stub
        expect(Statsd).not_to receive(:count).with('lhc.dummy.test.local_ch.get.cache.miss', 1)
        expect(Statsd).not_to receive(:count).with('lhc.dummy.test.local_ch.get.cache.hit', 1)
        LHC.get('http://local.ch')
        LHC.get('http://local.ch')
      end
    end
  end

  context 'wrong interceptor order' do
    before(:each) do
      LHC.config.interceptors = [LHC::Monitoring, LHC::Caching] # monitoring needs to be after Caching
    end

    it 'does monitors miss/hit for caching and warns about wrong order of interceptors' do
      stub
      expect(Statsd).not_to receive(:count).with('lhc.dummy.test.local_ch.get.cache.miss', 1)
      expect(Statsd).not_to receive(:count).with('lhc.dummy.test.local_ch.get.cache.hit', 1)
      expect(-> {
        LHC.get('http://local.ch', cache: true)
        LHC.get('http://local.ch', cache: true)
      }).to output("[WARNING] Your interceptors must include LHC::Caching and LHC::Monitoring and also in that order.\n[WARNING] Your interceptors must include LHC::Caching and LHC::Monitoring and also in that order.\n").to_stderr
    end
  end
end
