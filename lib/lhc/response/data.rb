require 'ostruct'
# Response data is data provided through the response body
# but made accssible in the ruby world
class LHC::Response::Data < OpenStruct

  def initialize(response)
    @response = response
    set_dynamic_accessor_methods
    super(as_json)
  end

  def as_json
    response.format.as_json(response)
  end

  def as_open_struct
    response.format.as_open_struct(response)
  end

  def [](key)
    @hash ||= as_json.with_indifferent_access
    @hash[key]
  end

  private

  attr_reader :response

  def set_dynamic_accessor_methods
    as_json.keys.each do |key|
      define_singleton_method key do |*args|
        as_open_struct.send key, *args
      end
    end
  end
end
