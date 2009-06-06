require 'rubygems'
require 'sinatra'
require 'erb'
require 'builder'
require 'sequel'
require File.dirname(__FILE__) + '/lib/helpers'

DB = Sequel.connect('sqlite://test.db')
set :picurl, "http://localhost/~kazuki/strage"

get '/' do
  erb :index
end

get '/thread/:id' do
  @board = DB[:boards][:id => params[:id]]
  pictures = DB[:pictures].filter(:board_id => params[:id]).map(:url)
  @count = pictures.count
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
  erb 'check'
end

get '/admin/info' do
  erb 'info'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def parts_board_list
    @parts_board_list_boards = DB[:boards].reverse_order(:updated_at).all
    partial "parts/board_list".to_sym
  end

  def parts_info
    partial "parts/info".to_sym
  end

  def parts_ad
    partial "parts/ad".to_sym
  end

  def picdata
    h = DB[:histories].reverse_order(:id).first
    "#{h[:count]} pieces(#{h[:size].to_i / (1024 * 1024)} Mbyte)"
  end
end

configure :production do
  not_found do
    '<div>404</div><div><a href="/">TOP</a></div>' 
  end
  error do
    '<div>500</div><div><a href="/">TOP</a></div>' 
  end
end
