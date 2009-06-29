port = request.port == 80 ? '' : ":" + request.port.to_s
base_url = request.scheme + '://' + request.host + port

xml.instruct!
xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
  xml.url do
    xml.loc(base_url + '/')
    xml.priority("1.0")
  end
  @boards.each do |b|
    xml.url do
      xml.loc("#{base_url}/thread/#{b[:id]}/#{u(b[:title])}")
      xml.priority("0.8")
    end
  end
end
