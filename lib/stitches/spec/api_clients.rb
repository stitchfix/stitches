module ApiClients
  def api_client(options = { name: "test" })
    ::ApiClient.where(name: options[:name]).first or ::ApiClient.create!(name: options[:name]).reload
  end
end
