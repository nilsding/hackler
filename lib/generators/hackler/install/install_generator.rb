# frozen_string_literal: true

class Hackler::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    copy_file "initializer.rb", "config/initializers/hackler.rb"
  end

  def install_route
    route %(mount Hackler::Engine => "/hackler")
  end

  def configure_active_job_adapter
    gsub_file Pathname(destination_root).join("config/environments/production.rb"),
              /(# )?config\.active_job\.queue_adapter\s+=.*/,
              "config.active_job.queue_adapter = :hackler"
  end

  def add_migrations
    rails_command "hackler:install:migrations"
  end
end
