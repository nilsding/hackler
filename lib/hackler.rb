# frozen_string_literal: true

require "hackler/version"
require "hackler/engine"

require "active_job"
require "active_job/queue_adapters"
require "active_record"

require "digest/sha2"
require "faraday"

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/generators")
loader.setup

module Hackler
  mattr_accessor :shared_secret, default: "hackme"

  # set to true if this is the instance that can actually run the jobs
  mattr_accessor :worker, default: false

  mattr_accessor :backtrace_cleaner, default: ->(backtrace) { ::Rails.backtrace_cleaner.clean(backtrace) }

  mattr_accessor :web_base_url

  mattr_accessor :worker_base_url

  # set this to the queue hackler should use in jobs
  mattr_accessor :worker_queue, default: :default

  def self.configure = yield self

  def self.build_secret(id:, base_url:, **)
    Digest::SHA512.base64digest([shared_secret, id, base_url].join(&:to_s))
  end

  def self.connection_for(url) = Faraday.new(url:) do |builder|
    builder.request :json
    builder.response :json
    builder.response :raise_error
  end

  # Base class for Hackler errors
  class Error < StandardError; end

  # Raised when a job failed
  class JobError < Error
    def self.from_json(json)
      message   = json.fetch(:message, "???")
      klass     = json.fetch(:class, "???")
      backtrace = json.fetch(:backtrace) { ["???"] * 5 }

      # sick ruby trick: create a new subclass and extend it with a module
      # which overwrites the exception class' name, in order to make it look
      # better in e.g. the sidekiq dashboards
      subclass = Class.new(self).extend(NameExtender.new(klass))
      subclass.new(message).tap do |exc|
        exc.set_backtrace backtrace
      end
    end

    class NameExtender < Module
      def initialize(name)
        super

        define_method :name do
          name
        end
      end
    end

    private_constant :NameExtender
  end
end
