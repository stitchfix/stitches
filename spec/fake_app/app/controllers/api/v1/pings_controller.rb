class Api::V1::PingsController < Api::ApiController

  def create
    if ping_params[:error]
      render json: { errors: Stitches::Errors.new([ Stitches::Error.new(code: "test", message: ping_params[:error]) ])} , status: 422
    else
      render json: { ping: { status: "ok" } }, status: (ping_params[:status] || "201").to_i
    end
  end

private

  def ping_params
    params.permit(:error, :status)
  end
end
