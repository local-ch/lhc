# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  context 'plain' do
    let(:file) { fixture_file_upload(Tempfile.new, 'image/jpeg') }

    it 'leaves plains requests unformatted' do
      stub_request(:post, 'http://local.ch/')
        .with(body: /file=%23%3CRack%3A%3ATest%3A%3AUploadedFile%3.*%3E&type=Image/)
        .to_return do |request|
          expect(request.headers['Content-Type']).to be_blank

          { status: 204 }
        end
      response = LHC.plain.post(
        'http://local.ch',
        body: { file: file, type: 'Image' }
      )
      expect(lambda {
        response.body
        response.data
      }).not_to raise_error
    end
  end
end
