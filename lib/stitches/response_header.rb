require_relative 'allowlist_middleware'

module Stitches
  class ResponseHeader < Stitches::AllowlistMiddleware
  protected
    def do_call(env)
      status, headers, body = @app.call(env)
      headers["Content-Type"] = env["CONTENT_TYPE"]
      [status, headers, body]
    end
  end
end
