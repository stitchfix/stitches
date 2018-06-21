desc "Generates a new API Key.  Requires a name, e.g. rake generate_api_key[YOUR_APP_NAME_HERE]"
task :generate_api_key, [:name] => :environment do |t, args|
  fail "Your environment does not allow API keys to be generated" if ENV["STITCHES_DISALLOW_GENERATE_API_KEY"]
  fail "You must provide a name" unless args.name
  api_client = ::ApiClient.create!(name: args.name)
  api_client.reload
  puts "Your key is #{api_client.key}"
  puts
  puts "You can test it via curl:"
  puts "curl -v -X POST -H 'Accept: application/json; version=1' -H 'Content-type: application/json; version=1' -H 'Authorization: CustomKeyAuth key=#{api_client.key}' https://your_app.herokuapp.com/api/ping"
end
