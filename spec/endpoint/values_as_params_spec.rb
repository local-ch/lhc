# frozen_string_literal: true

require 'rails_helper'

describe LHC::Endpoint do
  context 'values_as_params' do
    [
      ['{+datastore}/v2/places', 'http://local.ch:8082/v2/places', {
        datastore: 'http://local.ch:8082'
      }],
      ['{+datastore}/v2/places/{id}', 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A', {
        datastore: 'http://local.ch:8082',
        id: 'ZW9OJyrbt4OZE9ueu80w-A'
      }],
      ['{+datastore}/v2/places/{namespace}/{id}', 'http://local.ch:8082/v2/places/switzerland/ZW9OJyrbt', {
        datastore: 'http://local.ch:8082',
        namespace: 'switzerland',
        id: 'ZW9OJyrbt'
      }]
    ].each do |example|
      template = example[0]
      url = example[1]
      params = example[2]

      it "for the template #{template} it extracts #{params.keys.join(', ')} from the url" do
        extracted = LHC::Endpoint.values_as_params(template, url)
        expect(extracted).to eq(params)
      end
    end
  end
end
