# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  context 'interceptor' do
    before(:each) do
      class Services
        def self.timing(_path, _time); end
      end

      class StatsTimingInterceptor < LHC::Interceptor
        def after_response
          uri = URI.parse(response.request.url)
          path = [
            'web',
            ((ActiveSupport.gem_version >= Gem::Version.new('6.0.0')) ? Rails.application.class.module_parent_name : Rails.application.class.parent_name).underscore,
            Rails.env,
            response.request.method,
            uri.scheme,
            uri.host,
            response.code
          ].join('.')
          Services.timing(path.downcase, response.time)
        end
      end
      LHC.configure { |c| c.interceptors = [StatsTimingInterceptor] }
    end

    let(:url) { "http://local.ch/v2/feedbacks/-Sc4_pYNpqfsudzhtivfkA" }

    it 'can take action after a response was received' do
      allow(Services).to receive(:timing).with('web.dummy.test.get.http.local.ch.200', 0)
      stub_request(:get, url)
      LHC.get(url)
      expect(Services).to have_received(:timing)
    end
  end
end
