require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class Services

        def self.timing(path, time)
        end
      end
    end

    before(:each) do
      class StatsTimingInterceptor < LHC::Interceptor

        def after_response(response)
          uri = URI.parse(response.request.url)
          path = [
            'web',
            Rails.application.class.parent_name,
            Rails.env,
            response.request.method,
            uri.scheme,
            uri.host,
            response.code
          ].join('.')
          Services.timing(path.downcase, response.time)
        end
      end
      LHC.config.interceptors = [StatsTimingInterceptor]
    end

    let(:url) { "http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks/-Sc4_pYNpqfsudzhtivfkA" }

    it 'can take action after a response was received' do
      allow(Services).to receive(:timing).with('web.dummy.test.get.http.datastore-stg.lb-service.sunrise.intra.local.ch.200', 0)
      stub_request(:get, url)
      LHC.get(url)
      expect(Services).to have_received(:timing)
    end
  end
end
