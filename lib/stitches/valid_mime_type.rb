require_relative 'allowlist_middleware'
module Stitches
  # A middleware that requires all API calls to be for versioned JSON or Protobuf.
  #
  # This means that the Accept header (available to Rack apps as HTTP_ACCEPT) should be like so:
  #
  #     application/json; version=1
  #
  # This just checks that you've specified some numeric version.  ApiVersionConstraint should be used
  # to "lock down" the versions you accept.
  # 
  # Or in the case of a protobuf encoded payload the header should be like so:
  #
  #     application/protobuf
  #
  # There isn't an accepted standard for protobuf encoded payloads but this form is common.
  class ValidMimeType < Stitches::AllowlistMiddleware

  protected

    def do_call(env)
      accept = String(env["HTTP_ACCEPT"])
      if (%r{application/json}.match?(accept) && %r{version=\d+}.match?(accept)) || %r{application/protobuf}.match?(accept)
        @app.call(env)
      else
        not_acceptable_response(accept)
      end
    end

    private

    def not_acceptable_response(accept_header)
      status = 406
      body = "Not Acceptable - '#{accept_header}' didn't have the right mime type or version number. We only accept application/json with a version or application/protobuf"
      header = { "WWW-Authenticate" => accept_header }
      Rack::Response.new(body, status, header).finish
    end

  end
end
