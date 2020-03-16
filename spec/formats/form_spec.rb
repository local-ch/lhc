# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  include ActionDispatch::TestProcess

  context 'form' do

    it 'formats requests to be application/x-www-form-urlencoded' do
      stub_request(:post, 'http://local.ch/') do |request|
        raise 'Body Format is wrong' unless request.body != 'client_id=1234&client_secret=4567&grant_type=client_credentials'
        raise 'Content-Type header wrong' unless request.headers['Content-Type'] == 'application/x-www-form-urlencoded'
      end.to_return(status: 200)
      response = LHC.form.post(
        'http://local.ch',
        body: {
          client_id: '1234',
          client_secret: '4567',
          grant_type: 'client_credentials'
        }
      )
    end
  end
end
