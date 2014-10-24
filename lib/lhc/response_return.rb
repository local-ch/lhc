class LHC::ResponseReturn

  attr_accessor :response

  def initialize(response)
    self.response = response
  end
end

class LHC::ResponseInterrupt < LHC::ResponseReturn
end
