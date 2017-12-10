require 'oga'

path = File.expand_path("../tmp/119.245.150.160.html", __FILE__)
data = File.read(path)
html = Oga.parse_html(data)

arr = []
Dir.glob(File.expand_path("../tmp/*.html", __FILE__)).each do |path|
  data = File.read(path)
  begin
    html = Oga.parse_html(data)
    meta_tags = html.xpath('/html/head/meta[@name="generator"]/@content')
    meta = meta_tags.find do |tag|
      tag.text.start_with? "WordPress"
    end
    ver = meta.nil? ? "N/A" : meta.text
  rescue => e
    ver = "N/A"
  end
  arr << [File.basename(path).split(".")[0..-2].join("."), ver]
end

arr.group_by { |e| e.last }.sort.each do |key, values|
  puts [key, values.length].join(",")
end