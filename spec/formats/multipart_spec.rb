# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  include ActionDispatch::TestProcess

  context 'multipart' do
    let(:file) { fixture_file_upload(Tempfile.new, 'image/jpeg') }
    let(:body) { { size: 2231 }.to_json }
    let(:location) { 'http://local.ch/uploads/image.jpg' }

    it 'formats requests to be multipart/form-data' do
      stub_request(:post, 'http://local.ch/') do |request|
        raise 'Content-Type header wrong' unless request.headers['Content-Type'] == 'multipart/form-data'
        raise 'Body wrongly formatted' unless request.body.match(/file=%23%3CActionDispatch%3A%3AHttp%3A%3AUploadedFile%3A.*%3E&type=Image/)
      end.to_return(status: 200, body: body, headers: { 'Location' => location })
      response = LHC.multipart.post(
        'http://local.ch',
        body: { file: file, type: 'Image' }
      )
      expect(response.body).to eq body
      expect(response.headers['Location']).to eq location
    end
  end
end
