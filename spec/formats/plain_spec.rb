require 'rails_helper'

describe LHC do
  context 'plain' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: Tempfile.new,
        filename: 'image.jpg',
        type: 'image/jpeg',
        head: %q{Content-Disposition: form-data; name="files[]"; filename="image.jpg"\r\nContent-Type: image/jpeg\r\n}
      )
    end

    it 'leaves plains requests unformatted' do
      stub_request(:post, 'http://local.ch/')
        .with(body: /file=%23%3CActionDispatch%3A%3AHttp%3A%3AUploadedFile%3A.*%3E&type=Image/)
        .to_return do |request|
          raise 'Content-Type should not be set' if request.headers['Content-Type']

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
