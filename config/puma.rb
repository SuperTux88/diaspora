require File.expand_path('../load_config', __FILE__)

daemonize

state_path '/var/run/diaspora/diaspora.state'
pidfile '/var/run/diaspora/diaspora.pid'
bind 'unix:///var/run/diaspora/diaspora.sock'

worker_timeout AppConfig.server.unicorn_timeout.to_i

stdout_redirect AppConfig.server.stdout_log.present? ? AppConfig.server.stdout_log.get : '/dev/null',
                AppConfig.server.stderr_log.present? ? AppConfig.server.stderr_log.get : '/dev/null'

environment AppConfig.server.rails_environment

workers 2
threads 4, 16
preload_app!
