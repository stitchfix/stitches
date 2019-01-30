module Stitches
  module Deprecation
    # Indicate that a previously-deprecated endpoint is now gone
    def gone!
      head 410
    end

    # Indicate that this endpoint is deprecated and will go away on the given date.
    #
    # gon_on: - date, as a string, when this endpoint will go away
    # block - the contents of the endpoint
    #
    # Example:
    #
    #     def show
    #       deprecated gone_on: "2019-04-09" do
    #         render widgets: { Widget.find(params[:id]) }
    #       end
    #     end
    def deprecated(gone_on:,&block)
      response.set_header("Sunset",Date.parse(gone_on).in_time_zone("GMT").midnight.strftime("%a, %e %b %Y %H:%M:%S %Z"))
      Rails.logger.info("DEPRECATED ENDPOINT #{request.method} to #{request.fullpath} requested by #{current_user.id}")
      block.()
    end
  end
end
