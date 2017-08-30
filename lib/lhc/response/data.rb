class LHC::Response::Data
  autoload :Base, 'lhc/response/data/base'
  autoload :Item, 'lhc/response/data/item'
  autoload :Collection, 'lhc/response/data/collection'

  include LHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    if as_json.is_a?(Hash)
      @_data = LHC::Response::Data::Item.new(response, data: data)
    elsif as_json.is_a?(Array)
      @_data = LHC::Response::Data::Collection.new(response, data: data)
    end
  end

  def method_missing(method, *args, &block)
    @_data.send(method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    @_data.respond_to?(method_name, include_private) || super
  end
end
