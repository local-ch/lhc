require 'rails_helper'

describe LHC::Request do
  context 'without an encoding setting' do
    it 'encodes array params in default rack format' do
      stub_request(:get, 'http://datastore/q?a%5B%5D=1&a%5B%5D=2&a%5B%5D=3')
      LHC.get('http://datastore/q', params: { a: [1, 2, 3] })
    end
  end

  context 'with encoding set to :rack' do
    it 'encodes array params in rack format' do
      stub_request(:get, 'http://datastore/q?a%5B%5D=1&a%5B%5D=2&a%5B%5D=3')
      LHC.get('http://datastore/q', params: { a: [1, 2, 3] }, params_encoding: :rack)
    end
  end

  context 'with encoding set to :multi' do
    it 'encodes array params in multi format' do
      stub_request(:get, 'http://datastore/q?a=1&a=2&a=3')
      LHC.get('http://datastore/q', params: { a: [1, 2, 3] }, params_encoding: :multi)
    end
  end
end
