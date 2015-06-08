require File.expand_path('../load_config', __FILE__)

daemonize

state_path '/var/run/diaspora/diaspora.state'
pidfile '/var/run/diaspora/diaspora.pid'
bind AppConfig.server.listen.get

worker_timeout AppConfig.server.unicorn_timeout.to_i

stdout_redirect AppConfig.server.stdout_log? ? AppConfig.server.stdout_log.get : '/dev/null',
                AppConfig.server.stderr_log? ? AppConfig.server.stderr_log.get : '/dev/null'

environment 'production'

workers AppConfig.server.unicorn_worker.to_i
threads 4, 16
preload_app!
