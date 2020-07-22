# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  it 'adds the api key to the header of every request' do
    options = { api_key: { key: 'apitoken', value: '5hguebb44', add_to: :header } }
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    stub_request(:get, 'http://local.ch').with(headers: { 'apitoken' => '5hguebb44' })
    LHC.get(:local)
  end

  it 'adds the api key to the body of every request' do
    options = { api_key: { key: 'userToken', value: 'dheur5hrk3', add_to: :body } }
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    stub_request(:post, 'http://local.ch').with(body: {
                                                  'userToken' => 'dheur5hrk3',
                                                  'foo' => 'bar'
                                                })
    LHC.post(:local, body: { 'foo' => 'bar' })
  end
end
