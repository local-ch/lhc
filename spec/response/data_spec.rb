require 'rails_helper'

describe LHC::Response do
  context 'data' do
    let(:value) { 'some_value' }

    let(:raw_response) { OpenStruct.new(body: body.to_json) }

    let(:response) { LHC::Response.new(raw_response, nil) }

    context 'for item' do
      let(:body) { { some_key: { nested: value } } }

      it 'makes data from response body available' do
        expect(response.data.some_key.nested).to eq value
      end

      it 'makes data from response body available with hash bracket notation' do
        expect(response.data[:some_key][:nested]).to eq value
      end

      it 'can be converted to json with the as_json method' do
        expect(response.data.as_json).to eq body.as_json
      end

      it 'can be converted to an open struct with the as_open_struct method' do
        expect(response.data.as_open_struct).to eq JSON.parse(response.body, object_class: OpenStruct)
      end

      it 'returns nil when data is not available' do
        expect(response.data.something).to be_nil
      end
    end

    context 'for collection' do
      let(:body) { [{ some_key: { nested: value } }] }

      it 'can be converted to json with the as_json method' do
        expect(response.data.as_json).to eq body.as_json
      end

      it 'can be converted to an open struct with the as_open_struct method' do
        expect(response.data.as_open_struct).to eq JSON.parse(response.body, object_class: OpenStruct)
      end

      it 'is a collection of items' do
        expect(response.data.size).to eq(1)
      end

      it 'makes item data from response body available' do
        expect(response.data.first.some_key.nested).to eq value
      end

      it 'makes item data from response body available with hash bracket notation' do
        expect(response.data.first[:some_key][:nested]).to eq value
      end
    end
  end
end
