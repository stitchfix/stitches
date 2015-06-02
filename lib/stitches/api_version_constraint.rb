module Stitches
  # A routing constraint to route versioned requests to the right controller.
  # This allows you to organize your code around version numbers without requiring that clients
  # put version numbers in their URLs.  It's expected that you've set up ValidMimeType
  # as a middleware to ensure these numbers exist
  #
  # Example
  #
  #    namespace :api do
  #      scope module: :v1, constraints: Stitches::ApiVersionConstraint.new(1) do
  #        resource 'ping', only: [ :create ]
  #      end
  #      scope module: :v2, constraints: Stitches::ApiVersionConstraint.new(2) do
  #        resource 'ping', only: [ :create ]
  #      end
  #    end
  #
  # This will route requests with ;version=1 to +Api::V1::PingsController+, while those
  # with ;version=2 will go to +Api::V2::PingsController+.
  #
  class ApiVersionConstraint
    def initialize(version)
      @version = version
    end

    def matches?(request)
      request.headers.fetch(:accept).include?("version=#{@version}")
    rescue KeyError
      false
    end
  end
end