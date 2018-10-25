require 'rails_helper'

describe LHC do
  context 'unformatted' do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: Tempfile.new(Rails.root.join('spec', 'support', 'image.jpg').to_s),
        filename: 'image.jpg',
        type: 'image/jpeg',
        head: %q{Content-Disposition: form-data; name="files[]"; filename="image.jpg"\r\nContent-Type: image/jpeg\r\n}
      )
    end

    it 'leaves unformatted requests unformatted' do
      LHC.unformatted.post(
        'http://local.ch',
        {
          body: { file: file, type: 'Image' }
        }
      )
    end
  end
end
