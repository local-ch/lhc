# frozen_string_literal: true

class LHC::Response::Data
  autoload :Base, 'lhc/response/data/base'
  autoload :Item, 'lhc/response/data/item'
  autoload :Collection, 'lhc/response/data/collection'

  include LHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    if as_json.is_a?(Hash)
      @base = LHC::Response::Data::Item.new(response, data: data)
    elsif as_json.is_a?(Array)
      @base = LHC::Response::Data::Collection.new(response, data: data)
    end
  end

  def method_missing(method, *args, &block) # rubocop:disable Style/MethodMissingSuper
    @base.send(method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    @base.respond_to?(method_name, include_private) || super
  end
end
