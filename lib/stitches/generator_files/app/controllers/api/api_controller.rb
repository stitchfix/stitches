class Api::ApiController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |type|
      type.json { render json: { errors: Stitches::Errors.new([ Stitches::Error.new(code: "not_found", message: exception.message) ]) }, status: 404 }
      type.all  { render :nothing => true, :status => 404 }
    end
  end

  def current_user
    api_client
  end

protected

  def api_client
    @api_client ||= ::ApiClient.find(request.env[Stitches.configuration.env_var_to_hold_api_client_primary_key])
  end

end
