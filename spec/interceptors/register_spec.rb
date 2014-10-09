require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class TrackingIdInterceptor < LHC::Interceptor
      end
    end

    it 'is registered when inherit from LHC::Interceptor' do
      expect(LHC::Interceptor.interceptors.first).to be_kind_of TrackingIdInterceptor
    end
  end
end
