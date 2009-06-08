require 'rubygems'
require 'sinatra'
require 'erb'
require 'builder'
require 'sequel'
require File.dirname(__FILE__) + '/lib/helpers'

get '/' do
  erb :index
end

get '/thread/:id' do
  @board = DB[:boards][:id => params[:id]]
  pictures = DB[:pictures].filter(:board_id => params[:id]).map(:url)
  @count = pictures.length
  @urls = pictures.join(':')
  erb :thread
end

get '/feed' do
  @feeds = DB[:feeds].reverse_order(:id).limit(10)
  content_type "application/xml+atom"
  builder :feed
end

get '/star/:id' do
  begin
    if params[:id]
      board = DB[:boards].filter(:id => params[:id])
      board.update(:star => board.first[:star] + 1, :updated_at => Time.now)
    end
    'OK'
  rescue
    'NG'
  end
end

get '/admin' do
  erb '<h2>admin</h2><a href="/admin/check">check</a><br /><a href="/admin/info">info</a>'
end

get '/admin/check' do
  p = params[:p] || 1
  p = p.to_i
  @pictures = DB[:pictures].select(:pictures__url).select_more(:boards__thread_id).
    join(:boards, :id => :board_id).reverse_order(:pictures__id).limit(50, (p - 1) * 50)
  @paginate = "" 
  if p > 1
    @paginate << %{<a href="/admin/check?p=#{p - 1}">prev</a>}
    @paginate << %{<a href="/admin/check?p=#{p + 1}">next</a>}
  elsif
    @paginate << %{<a href="/admin/check?p=#{p + 1}">next</a>}
  end
  erb :check
end

get '/admin/info' do
  erb 'info'
end

##

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def parts_board_list
    ds = DB[:boards].reverse_order(:updated_at)
    @boards, @paginate = paginate(ds, params[:p] || 1)
    partial "parts/board_list".to_sym
  end

  def parts_info
    partial "parts/info".to_sym
  end

  def parts_ad
    partial "parts/ad".to_sym
  end

  def picurl
    options.picurl
  end

  def picdata
    h = DB[:histories].reverse_order(:id).first
    "#{h[:count]} pieces(#{h[:size].to_i / (1024 * 1024)} Mbyte)"
  end

  def paginate(ds, page)
    limit = 100
    page = page.to_i
    offset = (page - 1) * limit
    count = ds.count

    p_max = (count.to_f / limit).ceil

    html = []
    (1..p_max).each do |i|
      if i == page
        html << %{<span class="disable_page">#{i}</span>}
      else
        html << %{<a href="#{request.path}?p=#{i}"><span class="enable_page">#{i}</span></a>}
      end
    end
    [ds.limit(limit, offset).all, %{<div class="paginate">#{html.join}</div>}]
  end
end

##

configure :production do
  DB = Sequel.connect('sqlite:///home/gioext/pic2ch/db/production.sqlite3')
  set :picurl, "http://strage.pic2ch.giox.org"

  not_found do
    '<div>404</div><div><a href="/">TOP</a></div>' 
  end

  error do
    '<div>500</div><div><a href="/">TOP</a></div>' 
  end
end

configure :development do
  DB = Sequel.connect('sqlite://test.db')
  set :picurl, "http://localhost/~kazuki/strage"
end

