module Stitches
  class Error
    attr_reader :code, :message
    def initialize(options = {})
      [:code, :message].each do |key|
        unless options.has_key?(key)
          raise MissingParameter.new(self.class,key)
        end
      end

      @code    = options[:code]
      @message = options[:message]
    end

    class MissingParameter < StandardError
      def initialize(klass,param_name)
        super("#{ klass.name } must be initialized with :#{ param_name }")
      end
    end

  end
end
