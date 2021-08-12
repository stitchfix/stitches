class Api::V1::HellosController < Api::ApiController
  def show
    name = request.env[Stitches.configuration.env_var_to_hold_api_client]&.name || "NameNotFound"
    id =  request.env[Stitches.configuration.env_var_to_hold_api_client_primary_key] || "IdNotFound"
    render json: { hello: "Hello #{name}, your id is #{id}" }
  end
end
