module Stitches
  # A middleware that will skip its behavior if the path matches an allowed URL
  class AllowlistMiddleware
    def initialize(app, options={})
      @app           = app
      @configuration = options[:configuration]
      @except        = options[:except]

      allowlist_regex
    end

    def call(env)
      if allowlist_regex && allowlist_regex.match(env["PATH_INFO"])
        @app.call(env)
      else
        do_call(env)
      end
    end

  protected

    def do_call(env)
      raise 'subclass must implement'
    end

    def configuration
      @configuration || Stitches.configuration
    end

  private

    def allowlist_regex
      regex = @except || configuration.allowlist_regexp

      unless regex.nil? || regex.is_a?(Regexp)
        raise ":except must be a Regexp"
      end

      regex
    end
  end
end
