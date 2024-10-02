# frozen_string_literal: true

module Hackler
  class JobController < ApplicationController
    REQUIRED_PARAMS = %i[id base_url].freeze

    before_action :set_secret
    before_action :set_params
    before_action :verify_secret!

    def enqueue
      set_options = {}
      set_options[:wait_until] = Time.zone.at(@params[:timestamp]) if @params[:timestamp]

      Hackler::HacklerJob
        .set(**set_options)
        .perform_later(@params[:id], @params[:base_url])
      render head: :no_content
    end

    def work
      job = Hackler::Job.find(@params[:id])
      ActiveJob::Base.execute(JSON.parse(job.data))
      job.destroy!
      render head: :no_content
    rescue Exception => e # rubocop:disable Lint/RescueException
      # this needs to be a Exception, otherwise we won't catch e.g. `NoMethodError`s
      render json: {
        exception: {
          class:     e.class.name,
          message:   e.message,
          backtrace: Hackler.backtrace_cleaner.call(e.backtrace),
        },
      }, status: :internal_server_error
    end

    private

    def set_secret
      @header_secret = request.headers["x-hackler-secret"]
      return if @header_secret

      # pretend we're not there if the secret is missing
      render head: :not_found
    end

    def set_params
      @params = params.permit(:id, :base_url, :timestamp).to_h.symbolize_keys
      return if @params.keys.intersection(REQUIRED_PARAMS).size == 2

      render json: { error: "required parameters are missing" }, status: :unprocessable_content
    end

    def verify_secret!
      expected_secret = Hackler.build_secret(**@params)
      return if @header_secret == expected_secret

      render json: { error: "unauthorised" }, status: :unauthorized
    end
  end
end
