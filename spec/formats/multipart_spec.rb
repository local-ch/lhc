require 'rails_helper'

describe LHC do
  context 'multipart' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: Tempfile.new(Rails.root.join('spec', 'support', 'image.jpg').to_s),
        filename: 'image.jpg',
        type: 'image/jpeg',
        head: %q{Content-Disposition: form-data; name="files[]"; filename="image.jpg"\r\nContent-Type: image/jpeg\r\n}
      )
    end
    let(:body) { { size: 2231 }.to_json }
    let(:location) { 'http://local.ch/uploads/image.jpg' }

    it 'leaves plains requests unformatted' do
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
