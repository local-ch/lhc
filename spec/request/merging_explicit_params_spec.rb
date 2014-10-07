require 'rails_helper'

describe LHC::Request do

  it 'is using params as query params explicitly when provided in params namespace to prevent clashing from injections' do
    stub_request(:get, "http://example.com/resource?token=123").to_return(status: 200)
    LHC::Request.new(url: 'http://example.com/resource', params: { params: { token: '123' }})
  end
end
