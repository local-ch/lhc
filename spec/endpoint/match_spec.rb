require 'rails_helper'

describe LHC::Endpoint do

  context 'match' do

    context 'matching' do
      it 'checks if a url matches a template' do
        {
          ':datastore/v2/places' => 'http://local.ch:8082/v2/places',
          ':datastore/v2/places/:id' => 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
          ':datastore/v2/places/:namespace/:id' => 'http://local.ch:8082/v2/places/switzerland/ZW9OJyrbt'
        }.each do |template, url|
          expect(
            LHC::Endpoint.match?(url, template)
          ).to be, "#{url} should match #{template}!"
        end
      end
    end

    context 'not matching' do
        it 'checks if a url matches a template' do
          {
            ':datastore/v2/places' => 'http://local.ch:8082/v2/places/ZW9OJyrbt4OZE9ueu80w-A',
            ':datastore/:campaign_id/feedbacks' => 'http://datastore.local.ch/feedbacks'
          }.each do |template, url|
            expect(
              LHC::Endpoint.match?(url, template)
            ).not_to be, "#{url} should not match #{template}!"
          end
        end
    end
  end
end
