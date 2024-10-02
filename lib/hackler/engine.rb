# frozen_string_literal: true

module Hackler
  class Engine < ::Rails::Engine
    isolate_namespace Hackler
    config.generators.api_only = true
  end
end
