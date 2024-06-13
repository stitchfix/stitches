require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Ping (V1)" do
  include ApiClients
  header "Accept", "application/json; version=1"
  header "Content-Type", "application/json; version=1"

  post "/api/ping" do
    response_field :ping, "The name of the ping", "Type" => "Object"
    response_field :status, "The status of the ping", scope: "ping", "Type" => "String"
    example "ping the server to validate your client's happy path" do

      # Only needed if you're using API Key authentication
      # header "Authorization", "CustomKeyAuth key=#{api_client.key}"
      do_request

      result = JSON.parse(response_body)
      expect(result).to eq({ "ping" =>  { "status" => "ok" }})

      expect(status).to eql 201

    end
  end
  post "/api/ping" do
    parameter :error, "If set, will return an error instead of ok", "Type" => "Object"

    response_field :errors, "Array of errors", "Type" => "Array"
    response_field :code, "Programmer key describing the error (useful for logic)", scope: "errors", "Type" => "String"
    response_field :message, "Human-readable error message", scope: "errors", "Type" => "String"

    let(:error) { "OH NOES!" }
    let(:raw_post) { params.to_json }

    example "ping the server to validate your client's error handling" do

      # Only needed if you're using API Key authentication
      # header "Authorization", "CustomKeyAuth key=#{api_client.key}"
      do_request

      result = JSON.parse(response_body)
      expect(result).to eq({ "errors" => [ { "code" => "test", "message" => "OH NOES!" }]})

      expect(status).to eql 422

    end
  end
end
