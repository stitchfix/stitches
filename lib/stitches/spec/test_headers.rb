class TestHeaders
  include ApiClients
  def initialize(options={})
    full_mimetype = mime_type(options)
    @headers = {
      "Accept"       => full_mimetype,
      "Content-Type" => full_mimetype,
    }.tap { |headers|
      set_authorization_header(headers,options)
    }
  end

  def headers
    @headers
  end

private

  def mime_type(options)
    version_number = if options.key?(:version)
      options.delete(:version)
    else
      "1"
    end
    version = "; version=#{version_number}" if version_number

    mime_type = if options.key?(:mime_type)
                  options.delete(:mime_type)
                else
                  "application/json"
                end

    "#{mime_type}#{version}"
  end

  def set_authorization_header(headers,options)
    return nil if Stitches.configuration.disable_api_key_support

    api_client_key = if options.key?(:api_client)
                       options.delete(:api_client).try(:key)
                     else
                       api_client.key
                     end
    if api_client_key
      if api_client_key.kind_of?(Array)
        headers["Authorization"] = api_client_key.join(" ")
      else
        headers["Authorization"] = "#{Stitches.configuration.custom_http_auth_scheme} key=#{api_client_key}"
      end
    end
  end

end
