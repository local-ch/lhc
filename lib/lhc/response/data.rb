class LHC::Response::Data
  autoload :Base, 'lhc/response/data/base'
  autoload :Item, 'lhc/response/data/item'
  autoload :Collection, 'lhc/response/data/collection'

  include LHC::Response::Data::Base

  def initialize(response)
    @response = response

    if as_json.is_a?(Hash)
      @_data = LHC::Response::Data::Item.new(response)
    elsif as_json.is_a?(Array)
      @_data = LHC::Response::Data::Collection.new(response)
    end
  end

  def method_missing(method, *args, &block)
    @_data.send(method, *args, &block)
  end
end
