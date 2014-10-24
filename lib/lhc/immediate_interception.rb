class LHC::ImmediateInterception < StandardError

  attr_accessor :response

  def initialize(message, response = nil)
    super(message)
    self.response = response
  end

end
