class LHC::Response::Data::Collection < Array
  include LHC::Response::Data::Base

  def initialize(response)
    @response = response

    super(as_json.map { |i| LHC::Response::Data::Item.new(response, data: i.with_indifferent_access })
  end
end
