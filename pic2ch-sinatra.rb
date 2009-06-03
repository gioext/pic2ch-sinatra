require 'rubygems'
require 'sinatra'
require 'erb'
require 'sequel'

DB = Sequel.connect('sqlite://test.db')

configure do
  set :picurl, "/strage"
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def parts_board_list
    @parts_board_list_boards = DB[:boards].reverse_order(:id).all
    erb "parts/board_list".to_sym
  end

  def parts_info
    erb "parts/info".to_sym
  end

  def parts_ad
    erb "parts/ad".to_sym
  end

  def parts_footer
    erb "parts/footer".to_sym
  end

  def picurl
    options.picurl
  end
end

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
end

configure :production do
  not_found do
    '<div>404</div><div><a href="/">TOP</a></div>' 
  end
  error do
    '<div>500</div><div><a href="/">TOP</a></div>' 
  end
end

get '/a' do
  options.picurl
end
