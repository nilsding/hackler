# frozen_string_literal: true

Hackler.configure do |config|
  # change this to an actual secret string
  config.shared_secret = "hackme"

  # `false` if this is the web app, `true` if this is the Hackler worker
  config.worker = false

  # set this to the base url where Hackler gets mounted in your app
  config.web_base_url = "https://webapp.example.com/hackler"

  # set this to where the Hackler worker runs
  config.worker_base_url = "https://hackler.example.com/hackler"

  # define a custom backtrace cleaner
  # config.backtrace_cleaner = ->(backtrace) { ::Rails.backtrace_cleaner.clean(backtrace) }
end
