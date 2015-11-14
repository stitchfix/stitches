module Stitches
  class Error
    class MissingParameter < StandardError; end

    attr_reader :code, :message
    def initialize(options = {})
      [:code, :message].each do |key|
        unless options.has_key?(key)
          raise MissingParameter, "#{ self.class.name } must be initialized with :#{ key }"
        end
      end

      @code    = options[:code]
      @message = options[:message]
    end
  end
end
