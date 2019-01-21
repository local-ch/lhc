# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  context 'formats' do
    it 'adds Content-Type and Accept Headers to the request' do
      stub_request(:get, "http://local.ch/")
        .with(headers: { 'Accept' => 'application/json; charset=utf-8', 'Content-Type' => 'application/json; charset=utf-8' })
        .to_return(body: {}.to_json)
      LHC.json.get('http://local.ch')
    end

    context 'header key as symbol' do
      it 'raises an error when trying to set content-type header even though the format is used' do
        expect(lambda {
          LHC.post(
            'http://local.ch',
            headers: {
              'Content-Type': 'multipart/form-data'
            }
          )
        }).to raise_error 'Content-Type header is not allowed for formatted requests!'
      end

      it 'raises an error when trying to set accept header even though the format is used' do
        expect(lambda {
          LHC.post(
            'http://local.ch',
            headers: {
              'Accept': 'multipart/form-data'
            }
          )
        }).to raise_error 'Accept header is not allowed for formatted requests!'
      end
    end

    context 'header key as string' do
      it 'raises an error when trying to set content-type header even though the format is used' do
        expect(lambda {
          LHC.post(
            'http://local.ch',
            headers: {
              'Content-Type' => 'multipart/form-data'
            }
          )
        }).to raise_error 'Content-Type header is not allowed for formatted requests!'
      end

      it 'raises an error when trying to set accept header even though the format is used' do
        expect(lambda {
          LHC.post(
            'http://local.ch',
            headers: {
              'Accept' => 'multipart/form-data'
            }
          )
        }).to raise_error 'Accept header is not allowed for formatted requests!'
      end
    end
  end
end
