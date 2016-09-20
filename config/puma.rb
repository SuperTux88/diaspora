require_relative "load_config"

state_path "/var/run/diaspora/diaspora.state"
pidfile "/var/run/diaspora/diaspora.pid"
bind AppConfig.server.listen.get

worker_timeout AppConfig.server.unicorn_timeout.to_i

stdout_redirect AppConfig.server.stdout_log? ? AppConfig.server.stdout_log.get : "/dev/null",
                AppConfig.server.stderr_log? ? AppConfig.server.stderr_log.get : "/dev/null"

environment "production"

plugin "tmp_restart"

workers AppConfig.server.unicorn_worker.to_i
threads 4, 16
preload_app!

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! # preloading app in master, so reconnect to DB

  # disconnect redis if in use
  unless AppConfig.environment.single_process_mode?
    Sidekiq.redis {|redis| redis.client.disconnect }
  end

  # start puma worker killer
  PumaWorkerKiller.config do |config|
    config.ram           = 1536 # mb
    config.frequency     = 60   # seconds
    config.percent_usage = 1
    config.rolling_restart_frequency = false
  end
  PumaWorkerKiller.start
end

on_worker_boot do
  Logging.reopen # reopen logfiles to obtain a new file descriptor

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection # preloading app in master, so reconnect to DB
  end

  # We don't generate uuids in the frontend, but let's be on the safe side
  UUID.generator.next_sequence
end
