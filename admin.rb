require 'rubygems'
require 'sinatra'
require 'erb'
require 'builder'
require 'sequel'
require File.dirname(__FILE__) + '/lib/helpers'

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

helpers do
  def static(path = nil)
    options.static_url + path.to_s
  end
  def picdata
    "#{last_history[:count]}Pieces/#{last_history[:size].to_i / (1024 * 1024)}Mbyte"
  end
  def last_history
    @last_history ||= DB[:histories].reverse_order(:id).first
  end
  def last_updated
    last_history[:value].gsub('.', '/')
  end
end

##

configure :production, :test do
  DB = Sequel.connect('sqlite:///home/gioext/pic2ch/db/production.sqlite3')
  set :static_url, "http://strage.orelog.us"

  not_found do
    '<div>404</div><div><a href="/">TOP</a></div>' 
  end

  error do
    '<div>500</div><div><a href="/">TOP</a></div>' 
  end
end

configure :development do
  DB = Sequel.connect('sqlite://dev.db')
  set :static_url, "/"
end

