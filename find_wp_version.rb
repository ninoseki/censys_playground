## make a stas of WP version/plugin from HTMLs
require 'oga'

def WP_xmlrpc(data)
  data.lines.any? { |line| line.include? "/xmlrpc.php" }
end

def WP_plugins(data)
  plugins = []
  begin
    html = Oga.parse_html(data)
    links = html.xpath('//@href | //@src').map(&:value)
    plugin_links = links.find_all{ |e| e.include?('/wp-content/plugins/') }
    plugin_links.each do |link|
      link_parts = link.split('/')
      plugins << link_parts[link_parts.index('plugins') + 1]
    end
  rescue LL::ParserError => e
    raise e
  end
  plugins.uniq
end

def WP_version(data)
  ver = "N/A"
  begin
    html = Oga.parse_html(data)
    meta_tags = html.xpath('/html/head/meta[@name="generator"]/@content')
    # Search a metatag
    meta = meta_tags.find do |tag|
      tag.text.start_with? "WordPress"
    end
    ver = meta.nil? ? "N/A" : meta.text
  rescue LL::ParserError => e
    raise e
  end
  ver
end

versions = []
plugins = []
xmlrpcs = []
Dir.glob(File.expand_path("../tmp/**/*.html", __FILE__)).each do |path|
  data = File.read(path)
  ip = File.basename(path).split(".")[0..-2].join(".")
  begin
    versions << [ip, WP_version(data)]
    plugins << [ip, WP_plugins(data)]
    xmlrpcs << [ip, WP_xmlrpc(data)]
  rescue LL::ParserError => e
    puts "Cannot parse: #{path} (#{e})"
  end
end

# Make a stats of WP version
puts "Version Stats"
versions.group_by(&:last).sort.each do |key, values|
  puts [key, values.length].join(",")
end
puts "---"
# Make a stats of WP plugin
puts "Plugin Stats"
plugins.map(&:last).flatten.group_by(&:itself).map do |k, v|
  [k, v.length]
end.sort_by(&:last).each do |k, v|
  puts [k, v].join(",")
end
puts "---"
# Make a stats of XMLRPC
xmlrpcs.group_by(&:last).each do |key, values|
  puts [key, values.length].join(",")
end
