# frozen_string_literal: true

class LHC::Response::Data::Collection < Array
  include LHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    super(
      as_json.map do |i|
        LHC::Response::Data.new(response, data: i)
      end
    )
  end
end
