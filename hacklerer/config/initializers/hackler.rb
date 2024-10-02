# frozen_string_literal: true

Hackler.configure do |config|
  # change this to an actual secret string
  config.shared_secret = "hackme"

  # `false` if this is the web app, `true` if this is the Hackler worker
  config.worker = true

  # queue name where Hackler jobs will be processed
  config.worker_queue = :default
end

# record backtraces by default
Sidekiq.default_job_options = { backtrace: true } unless ENV.key?("SIDEKIQ_DISABLE_BACKTRACES")

Sidekiq.configure_server do |config|
  # record full backtraces, they are cleaned by the hackler worker
  config[:backtrace_cleaner] = ->(backtrace) { backtrace }
end
