# frozen_string_literal: true

module Hackler
  class ApplicationController < ActionController::API
    wrap_parameters false
  end
end
