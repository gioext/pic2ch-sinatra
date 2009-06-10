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
  unless @board
    halt erb(:del)
  end
  pictures = DB[:pictures].filter(:board_id => params[:id]).map(:url)
  @count = pictures.length
  @urls = pictures.join(':')
  erb :thread
end

get '/feed' do
  @feeds = DB[:feeds].reverse_order(:id).limit(10)
  content_type "application/atom+xml"
  builder :feed
end

get '/star/:id' do
  begin
    if params[:id]
      board = DB[:boards].filter(:id => params[:id])
      board.update(:star => board.first[:star] + 1, :updated_at => Time.now.getgm)
    end
    'OK'
  rescue
    'NG'
  end
end

##

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def parts_board_list
    ds = DB[:boards].reverse_order(:updated_at)
    @boards, @paginate = paginate(ds, params[:p] || 1)
    partial :list
  end

  def parts_info
    partial :info
  end

  def parts_ad
    partial :ad
  end

  def static(path = nil)
    options.static_url + path.to_s
  end

  def title(board)
    title = board[:title].strip
    now = Time.now
    create = local_time(board[:created_at])

    if (now - create).abs < (3600 * 12)
      %{<span class="new">#{title}</span>}
    else
      title
    end
  end

  def last_history
    @last_history ||= DB[:histories].reverse_order(:id).first
  end

  def picdata
    "#{last_history[:count]}Pieces/#{last_history[:size].to_i / (1024 * 1024)}Mbyte"
  end

  def last_updated
    last_history[:value].gsub('.', '/')
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

configure :production, :test do
  DB = Sequel.connect('sqlite:///home/gioext/pic2ch/db/production.sqlite3')
  set :static_url, "http://strage.orelog.us"

  not_found do
    erb '<div>404</div>'
  end

  error do
    erb '<div>500</div>'
  end
end

configure :development do
  DB = Sequel.connect('sqlite://dev.db')
  set :static_url, ""
end

