module ApiClients
  def api_client(name: "test")
    ::ApiClient.where(name: name).first or ::ApiClient.create!(name: name).reload
  end
end
