require 'rails_helper'

describe LHC::Endpoint do

  context 'values_as_params' do

    it 'provides params extracting values from a provided url and template' do
      [
        [':datastore/v2/places', 'http://local.ch:8082/v2/places', {
          datastore: 'http://local.ch:8082'
        }],
        [':datastore/v2/places/:id', 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A', {
          datastore: 'http://local.ch:8082',
          id: 'ZW9OJyrbt4OZE9ueu80w-A'
        }],
        [':datastore/v2/places/:namespace/:id', 'http://local.ch:8082/v2/places/switzerland/ZW9OJyrbt', {
          datastore: 'http://local.ch:8082',
          namespace: 'switzerland',
          id: 'ZW9OJyrbt'
        }],
      ].each do |example|
        params = LHC::Endpoint.values_as_params(example[0], example[1])
        expect(params).to eq example[2]
      end
    end
  end
end
