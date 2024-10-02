# frozen_string_literal: true

module Hackler
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
