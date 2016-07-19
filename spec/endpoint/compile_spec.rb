require 'rails_helper'

describe LHC::Endpoint do
  context 'compile' do
    it 'uses parameters for interpolation' do
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      expect(
        endpoint.compile(datastore: 'http://datastore', campaign_id: 'abc')
      ).to eq "http://datastore/v2/abc/feedbacks"
    end

    it 'uses provided proc to find values' do
      endpoint = LHC::Endpoint.new(':datastore/v2')
      config = { datastore: 'http://datastore' }
      find_value = lambda { |match|
        config[match.gsub(':', '').to_sym]
      }
      expect(
        endpoint.compile(find_value)
      ).to eq "http://datastore/v2"
    end

    it 'compiles when templates contain dots' do
      endpoint = LHC::Endpoint.new(':datastore/entries/:id.json')
      expect(
        endpoint.compile(datastore: 'http://datastore', id: 123)
      ).to eq "http://datastore/entries/123.json"
    end

    it 'compiles complex urls containing all sort of characters' do
      endpoint = described_class.new(':ads/?adrawdata/3.0/1108.1/2844859/0/0/header=yes;cookie=no;adct=204;alias=:region_id:lang:product_type:product;key=cat=:category_id')
      expect(
        endpoint.compile(ads: 'http://ads', region_id: 291, lang: 'de', product_type: 'ABC', product: 'xyz', category_id: 312)
      ).to eq 'http://ads/?adrawdata/3.0/1108.1/2844859/0/0/header=yes;cookie=no;adct=204;alias=291deABCxyz;key=cat=312'
    end
  end
end
