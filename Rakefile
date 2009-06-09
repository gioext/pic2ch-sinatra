SERVER = "gioext@giox.org"
APP_ROOT = "/home/gioext/pic2ch-sinatra"

desc "deploy"
task :deploy do
  sh "rsync -avz --delete --exclude '.*' --exclude '*.db' --exclude 'log/*' --exclude 'public/pics3' --exclude 'public/thumbs' ./ #{SERVER}:#{APP_ROOT}"
end

desc "restart"
task :restart do
  sh "ssh #{SERVER} touch #{APP_ROOT}/tmp/restart.txt"
end

