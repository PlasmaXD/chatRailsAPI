# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.

# Specifies that the worker count should equal the number of processors in production.
# if ENV["RAILS_ENV"] == "production"
#   require "concurrent-ruby"
#   worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
#   workers worker_count if worker_count > 1
# end
# ワーカー数を 1 に固定
# worker_count = ENV.fetch("WEB_CONCURRENCY") { 1 }
# workers worker_count
# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
# worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# config/puma.rb

# config/puma.rb

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# クラスターモードを無効にするため、ワーカーの設定を削除またはコメントアウト
# worker_count = ENV.fetch("WEB_CONCURRENCY") { 1 }
# workers worker_count if worker_count > 1

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Cloud Run のデフォルトポート 8080 を使用
port ENV.fetch("PORT") { 8080 }
bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 8080 }}"

environment ENV.fetch("RAILS_ENV") { "production" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# ログを標準出力と標準エラーにリダイレクト
stdout_redirect "/dev/stdout", "/dev/stderr", true
log_requests true
# Puma を再起動可能にする
plugin :tmp_restart
