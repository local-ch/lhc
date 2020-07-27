# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  it 'adds body authentication to the existing request body' do
    stub_request(:post, "http://local.ch/")
      .with(body: {
        message: 'body',
        userToken: 'dheur5hrk3'
      }.to_json)

    LHC.post('http://local.ch', auth: { body: { userToken: 'dheur5hrk3' } }, body: {
      message: 'body'
    })
  end

  it 'adds body authentication to an empty request body' do
    stub_request(:post, "http://local.ch/")
      .with(body: {
        userToken: 'dheur5hrk3'
      }.to_json)

    LHC.post('http://local.ch', auth: { body: { userToken: 'dheur5hrk3' } })
  end

  it 'adds nothing if request method is GET' do
    stub_request(:get, "http://local.ch/")

    LHC.get('http://local.ch', auth: { body: { userToken: 'dheur5hrk3' } })
  end
end
