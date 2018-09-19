class Api::ApiController < ActionController::Base
  include Stitches::Deprecation
  #
  # The order of the rescue_from blocks is important - ActiveRecord::RecordNotFound must come after StandardError,
  # otherwise ActiveRecord::RecordNotFound exceptions will get rescued in the StandardError block.
  # See the documentation for rescue_from for further explanation:
  # https://apidock.com/rails/ActiveSupport/Rescuable/ClassMethods/rescue_from
  # Specifically, this part: "Handlers are inherited. They are searched from right to left, from bottom to top, and up
  # the hierarchy."
  #
  rescue_from StandardError do |exception|
    render json: { errors: Stitches::Errors.from_exception(exception) }, status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: Stitches::Errors.from_exception(exception) }, status: :not_found
  end

  def current_user
    api_client
  end

protected

  def api_client
    @api_client ||= request.env[Stitches.configuration.env_var_to_hold_api_client]
    # Use this if you want to look up the ApiClient instead of using the one placed into the env
    # @api_client ||= ApiClient.find(request.env[Stitches.configuration.env_var_to_hold_api_client_primary_key])
  end

end
