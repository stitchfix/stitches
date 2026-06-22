module Stitches
  # Lightweight stand-in for ApiClient when the caller is identified by
  # the calling service header rather than an API key lookup. Implements
  # the same interface (.name, .id, .key) so existing code that reads
  # the caller identity object continues to work.
  CallingServiceClient = Struct.new(:name) do
    def id
      nil
    end

    def key
      nil
    end
  end
end
