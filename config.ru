require File.join(File.dirname(__FILE__), 'pic2ch-sinatra.rb')

set :run, false
set :environment, :test
run Sinatra::Application
