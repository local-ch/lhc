require 'rails_helper'

describe LHC::Endpoint do
  context 'match' do
    context 'matching' do
      {
        '{+datastore}/v2/places' => 'http://local.ch:8082/v2/places',
        '{+datastore}/v2/places/{id}' => 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
        '{+datastore}/v2/places/{namespace}/{id}' => 'http://local.ch:8082/v2/places/switzerland/ZW9OJyrbt',
        '{+datastore}/addresses/{id}' => 'http://local.ch/addresses/123',
        'http://local.ch/addresses/{id}' => 'http://local.ch/addresses/123',
        '{+datastore}/customers/{id}/addresses' => 'http://local.ch:80/server/rest/v1/customers/123/addresses',
        '{+datastore}/entries/{id}.json' => 'http://local.ch/entries/123.json',
        '{+datastore}/places/{place_id}/feedbacks' => 'http://local.ch/places/1/feedbacks?limit=10&offset=0',
        'http://local.ch/places/1/feedbacks' => 'http://local.ch/places/1/feedbacks?lang=en',
        'http://local.ch/places/1/feedbacks.json' => 'http://local.ch/places/1/feedbacks.json?lang=en'
      }.each do |template, url|
        it "#{url} matches #{template}" do
          expect(LHC::Endpoint.match?(url, template)).to be
        end
      end
    end

    context 'not matching' do
      {
        '{+datastore}/v2/places' => 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
        '{+datastore}/{campaign_id}/feedbacks' => 'http://datastore.local.ch/feedbacks',
        '{+datastore}/customers/{id}' => 'http://local.ch:80/server/rest/v1/customers/123/addresses',
        '{+datastore}/entries/{id}' => 'http://local.ch/entries/123.json'
      }.each do |template, url|
        it "#{url} should not match #{template}" do
          expect(
            LHC::Endpoint.match?(url, template)
          ).not_to be
        end
      end
    end
  end
end
