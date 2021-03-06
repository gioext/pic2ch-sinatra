port = request.port == 80 ? '' : ":" + request.port.to_s
base_url = request.scheme + '://' + request.host + port
feed_url = base_url + "/feed"
title = "2ch画像まとめ"
author_name = "skk"
author_uri = base_url

xml.instruct! :xml, :version => "1.0"
xml.feed(:xmlns => 'http://www.w3.org/2005/Atom') do
  xml.id      base_url + '/'
  xml.title   title
  xml.updated atom_time(@feeds.first[:datetime])
  xml.link(:rel => 'alternate', :href => "#{base_url}/")
  xml.link(:ref => 'self',      :href => feed_url)

  xml.author do
    xml.name  author_name
    xml.uri   author_uri
  end

  @feeds.each do |feed|
    xml.entry do
      created_at = atom_time(feed[:datetime])
      items = DB[:feed_items].filter(:feed_id => feed[:id]).all
      contents = items.map do |e|
        %{<a href="#{base_url}/thread/#{e[:board_id]}/#{u(e[:title])}">#{e[:title]}</a> #{e[:count]} pieces}
      end

      xml.id        "tag:" + base_url.gsub("http://", "") + "," + created_at
      xml.title     "#{title}(#{feed[:id]})", :type => 'html'
      xml.published created_at
      xml.updated   created_at
      xml.link(:rel => 'alternate', :href => "#{base_url}/?#{feed[:id]}")
      xml.content   contents.join('<br />'), :type => 'html'
#      xml.summary   "updated:#{feed[:created_at]}", :type => 'html'
    end
  end
end
