# frozen_string_literal: true

Rails.application.routes.draw do
  mount Hackler::Engine => "/hackler"
end
