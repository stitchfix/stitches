require_relative 'allowlist_middleware'
module Stitches
  # A middleware that requires all API calls to be for versioned JSON.  This means that the Accept
  # header (available to Rack apps as HTTP_ACCEPT) should be like so:
  #
  #     application/json; version=1
  #
  # This just checks that you've specified some numeric version.  ApiVersionConstraint should be used
  # to "lock down" the versions you accept.
  class ValidMimeType < Stitches::AllowlistMiddleware

  protected

    def do_call(env)
      accept = String(env["HTTP_ACCEPT"])
      if accept =~ %r{application/json} && accept =~ %r{version=\d+}
        @app.call(env)
      else
        not_acceptable_response(accept)
      end
    end

    private

    def not_acceptable_response(accept_header)
      status = 406
      body = "Not Acceptable - '#{accept_header}' didn't have the right mime type or version number. We only accept application/json with a version"
      header = { "WWW-Authenticate" => accept_header }
      Rack::Response.new(body, status, header).finish
    end

  end
end
