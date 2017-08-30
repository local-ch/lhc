class LHC::Response::Data::Item < OpenStruct
  include LHC::Response::Data::Base

  def initialize(response, data: nil)
    @response = response
    @data = data

    set_dynamic_accessor_methods

    super(as_json)
  end

  def [](key)
    @hash ||= as_json.with_indifferent_access
    @hash[key]
  end

  private

  def set_dynamic_accessor_methods
    as_json.keys.each do |key|
      define_singleton_method key do |*args|
        as_open_struct.send key, *args
      end
    end
  end
end
