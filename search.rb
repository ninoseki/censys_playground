require 'dotenv/load'
$:.unshift(File.expand_path('../lib', __FILE__))
require 'censys'

def file_path(ip)
  File.expand_path("../tmp/#{ip}.html", __FILE__)
end

def write_body(ip, body)
  File.open(file_path(ip), "w") { |f| f.write(body) }
end

query = ARGV[0]

api = CenSys::API.new(ENV["API_ID"], ENV["SECRET"])
response = api.ipv4.search(query: query)
response.each_page do |page|
  page.each do |result|
   ip = result["ip"]
   next if File.exists?(file_path(ip))
   view = api.view(:ipv4, ip)
   body = view.attributes.dig("80", "http", "get", "body")
    puts "processing: #{ip}"
    write_body ip, body
  end
end
