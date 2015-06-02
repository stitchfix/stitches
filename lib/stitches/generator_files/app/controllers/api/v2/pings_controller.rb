class Api::V2::PingsController < Api::ApiController

  def create
    respond_to do |format|
      format.json do
        if ping_params[:error]
          render json: { errors: Stitches::Errors.new([ Stitches::Error.new(code: "test", message: ping_params[:error]) ])} , status: 422
        else
          render json: { ping: { status_v2: "ok" } }, status: (ping_params[:status] || "201").to_i
        end
      end
    end
  end

private

  def ping_params
    params.permit(:error, :status)
  end
end
