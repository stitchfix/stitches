module Stitches
  # A middleware that will skip its behavior if the path matches an allowed URL
  class AllowlistMiddleware
    def initialize(app, options={})
      @app           = app
      @configuration = options[:configuration] ||  Stitches.configuration
      @except        = options[:except]        || @configuration.allowlist_regexp

      unless @except.nil? || @except.is_a?(Regexp)
        raise ":except must be a Regexp"
      end
    end
    def call(env)
      if @except && @except.match(env["PATH_INFO"])
        @app.call(env)
      else
        do_call(env)
      end
    end

  protected

    def do_call(env)
      raise 'subclass must implement'
    end

  end
end
