# frozen_string_literal: true

# Response data is data provided through the response body
# but made accssible in the ruby world
module LHC::Response::Data::Base
  def as_json
    @json ||= (@data || @response.format.as_json(@response.body))
  end

  def as_open_struct
    @open_struct ||=
      if @data
        JSON.parse(@data.to_json, object_class: OpenStruct)
      else
        @response.format.as_open_struct(@response.body)
      end
  end
end
