# Response data is data provided through the response body
# but made accssible in the ruby world
module LHC::Response::Data::Base
  def as_json
    @json ||= (@data || response.format.as_json(response))
  end

  def as_open_struct
    @open_struct ||= (@data || response.format.as_open_struct(response))
  end

  private

  attr_reader :response
end
