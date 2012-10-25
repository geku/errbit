APP_ROOT = Pathname.new(File.dirname(__FILE__)+'/..').realpath
 
require 'bundler/setup'

worker_processes 3
working_directory APP_ROOT.to_s
preload_app true
timeout 5
 
 
listen APP_ROOT.join('unicorn.sock').to_s, :backlog => 64
pid APP_ROOT.join("tmp/pids/unicorn.pid").to_s
 
Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new
 
stderr_path APP_ROOT.join("log/unicorn.stderr.log").to_s
stdout_path APP_ROOT.join("log/unicorn.stdout.log").to_s
 
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{APP_ROOT}/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
 
  old_pid = APP_ROOT.join('tmp/pids/unicorn.pid.oldbin').to_s
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end
 
after_fork do |server, worker|
  Bundler.setup
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end



