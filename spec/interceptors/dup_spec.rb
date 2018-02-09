require 'rails_helper'

describe LHC do
  context 'interceptor' do
    before(:each) do
      class SomeInterceptor < LHC::Interceptor
      end
    end

    it 'does not dup' do
      options = { interceptors: [SomeInterceptor] }
      expect(
        options.deep_dup[:interceptors].include?(SomeInterceptor)
      ).to eq true
    end
  end
end
