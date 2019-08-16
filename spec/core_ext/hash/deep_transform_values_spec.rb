# frozen_string_literal: true

require 'rails_helper'
require 'core_ext/hash/deep_transform_values'

describe Hash do
  subject do
    {
      'key' => 'value',
      'key2' => { 'key' => 'value', key2: 'value' }
    }
  end

  let(:expected_result) do
    {
      'key' => 'VALUE',
      'key2' => { 'key' => 'VALUE', key2: 'VALUE' }
    }
  end

  it 'applies upcase to all values' do
    expect(subject.deep_transform_values { |value| value.upcase }).to eq(expected_result)
  end
end
