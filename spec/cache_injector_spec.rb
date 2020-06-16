require 'spec_helper.rb'

module MyApp
  class Application
  end
end

unless defined? ApiClient
  class ApiClient
    def self.column_names
      ["enabled"]
    end
  end
end

describe Stitches::CacheInjector do
  let(:api_clients) {
    [
      double(ApiClient, id: 42)
    ]
  }

  before do
    expect(ApiClient).to receive(:where).and_return(api_clients).once
  end

  describe '#inject' do
    it "adds a method to the api client" do
      described_class.inject
      expect(ApiClient).to respond_to(:fetch_for_key)
      expect(ApiClient.fetch_for_key("123").id).to eq(42)
      # This should hit the cache
      expect(ApiClient.fetch_for_key("123").id).to eq(42)
    end
  end
end
