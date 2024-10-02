# frozen_string_literal: true

class Hackler::WorkerInstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    copy_file "initializer.rb", "config/initializers/hackler.rb"
  end

  def install_route
    route %(mount Hackler::Engine => "/hackler")
  end
end
