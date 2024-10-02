# frozen_string_literal: true

require_relative "lib/hackler/version"

Gem::Specification.new do |spec|
  spec.name        = "hackler"
  spec.version     = Hackler::VERSION
  spec.authors     = ["Jyrki Gadinger"]
  spec.email       = ["nilsding@nilsding.org"]
  spec.homepage    = "https://github.com/nilsding/hackler"
  spec.summary     = "A cursed approach to background jobs"
  spec.description = "A cursed approach to background jobs.  Here be dragons."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nilsding/hackler"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "faraday", "~> 2.12"
  spec.add_dependency "rails", ">= 7.2.1"

  spec.metadata["rubygems_mfa_required"] = "true"
end
