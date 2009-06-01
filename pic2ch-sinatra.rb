require 'rubygems'
require 'sinatra'
require 'erb'
require 'sequel'

DB = Sequel.connect('sqlite://test.db')

helpers do
  def parts_board_list
    @parts_board_list_boards = DB[:boards].reverse_order(:id).limit(10).all
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
end

get '/' do
  erb :index
end

get '/thread/:id' do
  @board = DB[:boards][:id => params[:id]]
  @pictures = DB[:pictures].filter(:board_id => params[:id]).all
  erb :thread
end
