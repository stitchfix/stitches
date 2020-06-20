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

describe Stitches::ApiKeyCacheWrapper do
  let(:api_client) {
    double(ApiClient, id: 42)
  }

  before do
    expect(ApiClient).to receive(:find_by).and_return(api_client).once
  end

  describe '#fetch_by_key' do
    it "fetchs object from cache" do
      expect(described_class.fetch_for_key("123").id).to eq(42)
      # This should hit the cache
      expect(described_class.fetch_for_key("123").id).to eq(42)
    end
  end
end
