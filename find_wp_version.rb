## make a stas of WP version/plugins from HTMLs
require 'oga'

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
  rescue => e; end
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
  rescue => e
    ver = "N/A (#{e}"
  end
  ver
end

versions = []
plugins = []
Dir.glob(File.expand_path("../tmp/**/*.html", __FILE__)).each do |path|
  data = File.read(path)
  ip = File.basename(path).split(".")[0..-2].join(".")
  versions << [ip, WP_version(data)]
  plugins << [ip, WP_plugins(data)]
end

# Make a stats of WP version
versions.group_by { |e| e.last }.sort.each do |key, values|
  puts [key, values.length].join(",")
end

# Make a stats of WP plugin
plugins.map(&:last).flatten.group_by(&:itself).map do |k, v|
  [k, v.length]
end.sort_by(&:last).each do |k, v|
  puts [k, v].join(",")
end