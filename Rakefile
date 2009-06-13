SERVER = "gioext@giox.org"
APP_ROOT = "/home/gioext/pic2ch-sinatra2"

desc "deploy"
task :deploy do
  exclude = ['public', 'log', 'tmp', '.*', '*.db']
  e = exclude.map! { |e| "--exclude '#{e}'" }.join(' ')
  sh "rsync -avz --delete #{e} ./ #{SERVER}:#{APP_ROOT}"
end

desc "restart"
task :restart do
  sh "ssh #{SERVER} touch #{APP_ROOT}/tmp/restart.txt"
end

