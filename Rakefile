require 'open-uri'
SERVER = "gioext@giox.org"
APP_ROOT = "/home/gioext/pic2ch-sinatra"

desc "deploy"
task :deploy do
  exclude = ['public/pics3', 'public/thumbs', 'log', 'tmp', '.*', '*.db']
  e = exclude.map! { |e| "--exclude '#{e}'" }.join(' ')
  sh "rsync -avz --delete #{e} ./ #{SERVER}:#{APP_ROOT}"
end

desc "restart"
task :restart do
  sh "ssh #{SERVER} touch #{APP_ROOT}/tmp/restart.txt"
  open('http://pic2ch.giox.org/expire-cache-all') do |f|
    f.read
  end
end

