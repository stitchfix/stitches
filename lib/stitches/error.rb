module Stitches
  class Error
    attr_reader :code, :message
    def initialize(options = {})
      @code    = options[:code]
      @message = options[:message]
    end
  end
end
