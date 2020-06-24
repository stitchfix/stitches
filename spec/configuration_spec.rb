require 'spec_helper.rb'

describe Stitches::Configuration do
  before do
    Stitches.configuration.reset_to_defaults!
  end

  describe "global configuration" do
    let(:allowlist_regexp) { %r{foo} }
    let(:custom_http_auth_scheme) { "Blah" }
    let(:env_var_to_hold_api_client_primary_key) { "FOOBAR" }
    let(:max_cache_ttl) { 11 }
    let(:max_cache_size) { 111 }

    it "can be configured globally" do
      Stitches.configure do |config|
        config.allowlist_regexp                       = allowlist_regexp
        config.custom_http_auth_scheme                = custom_http_auth_scheme
        config.env_var_to_hold_api_client_primary_key = env_var_to_hold_api_client_primary_key
        config.max_cache_ttl                          = max_cache_ttl
        config.max_cache_size                         = max_cache_size
      end

      expect(Stitches.configuration.allowlist_regexp).to                       eq(allowlist_regexp)
      expect(Stitches.configuration.custom_http_auth_scheme).to                eq(custom_http_auth_scheme)
      expect(Stitches.configuration.env_var_to_hold_api_client_primary_key).to eq(env_var_to_hold_api_client_primary_key)
      expect(Stitches.configuration.max_cache_ttl).to                          eq(max_cache_ttl)
      expect(Stitches.configuration.max_cache_size).to                         eq(max_cache_size)
    end

    it "defaults to nil for allowlist_regexp" do
      expect(Stitches.configuration.allowlist_regexp).to be_nil
    end

    it "sets a default for env_var_to_hold_api_client_primary_key" do
      expect(Stitches.configuration.env_var_to_hold_api_client_primary_key).to eq("STITCHES_API_CLIENT_ID")
    end

    it "defaults to 0 for max_cache_ttl" do
      expect(Stitches.configuration.max_cache_ttl).to eq(0)
    end

    it "sets a default for max_cache_size" do
      expect(Stitches.configuration.max_cache_size).to eq(0)
    end

    it "blows up if you try to use custom_http_auth_scheme without having set it" do
      expect {
        Stitches.configuration.custom_http_auth_scheme
      }.to raise_error(/you must set a value for custom_http_auth_scheme/i)
    end
  end
  describe "allowlist_regexp" do
    let(:config) { Stitches::Configuration.new }
    it "must be a regexp" do
      expect {
        config.allowlist_regexp = "foo"
      }.to raise_error(/allowlist_regexp must be a Regexp/i)
    end
    it "may be nil" do
      expect {
        config.allowlist_regexp = nil
      }.not_to raise_error
    end
    it "may be a regexp" do
      expect {
        config.allowlist_regexp = /foo/
      }.not_to raise_error
    end
  end

  describe "custom_http_auth_scheme" do
    let(:config) { Stitches::Configuration.new }
    it "must be a string" do
      expect {
        config.custom_http_auth_scheme = 42
      }.to raise_error(/custom_http_auth_scheme must be a String/i)
    end
    it "may not be nil" do
      expect {
        config.custom_http_auth_scheme = nil
      }.to raise_error(/custom_http_auth_scheme may not be blank/i)
    end
    it "may not be a blank string" do
      expect {
        config.custom_http_auth_scheme = "    "
      }.to raise_error(/custom_http_auth_scheme may not be blank/i)
    end
    it "may be a String" do
      expect {
        config.custom_http_auth_scheme = "Foobar"
      }.not_to raise_error
    end
  end

  describe "env_var_to_hold_api_client_primary_key" do
    let(:config) { Stitches::Configuration.new }
    it "must be a string" do
      expect {
        config.env_var_to_hold_api_client_primary_key = 42
      }.to raise_error(/env_var_to_hold_api_client_primary_key must be a String/i)
    end
    it "may not be nil" do
      expect {
        config.env_var_to_hold_api_client_primary_key = nil
      }.to raise_error(/env_var_to_hold_api_client_primary_key may not be blank/i)
    end
    it "may not be a blank string" do
      expect {
        config.env_var_to_hold_api_client_primary_key = "    "
      }.to raise_error(/env_var_to_hold_api_client_primary_key may not be blank/i)
    end
    it "may be a String" do
      expect {
        config.env_var_to_hold_api_client_primary_key = "Foobar"
      }.not_to raise_error
    end
  end

  describe "max_cache_ttl" do
    let(:config) { Stitches::Configuration.new }
    it "must be an integer" do
      expect {
        config.max_cache_ttl = ""
      }.to raise_error(/max_cache_ttl must be an Integer, not a String/)
    end

    it "may not be nil" do
      expect {
        config.max_cache_ttl = nil
      }.to raise_error(/max_cache_ttl must be an Integer, not a NilClass/)
    end
  end

  describe "max_cache_size" do
    let(:config) { Stitches::Configuration.new }
    it "must be an integer" do
      expect {
        config.max_cache_size = ""
      }.to raise_error(/max_cache_size must be an Integer, not a String/)
    end

    it "may not be nil" do
      expect {
        config.max_cache_size = nil
      }.to raise_error(/max_cache_size must be an Integer, not a NilClass/)
    end
  end

  context "deprecated options we want to support for backwards compatibility" do

    let(:logger) { double("logger") }
    before do
      allow(Rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
    end

    it "'whitelist' still works for allowlist" do
      Stitches.configure do |config|
        config.whitelist_regexp = /foo/
      end
      expect(Stitches.configuration.allowlist_regexp).to eq(/foo/)
    end
  end
end
