# frozen_string_literal: true

module Hackler
  class HacklerJob < ApplicationJob
    queue_as Hackler.worker_queue

    def perform(id, base_url)
      conn = Hackler.connection_for(base_url)
      parameters = {
        id:,
        base_url:,
      }
      begin
        conn.post("work", parameters, { "x-hackler-secret" => Hackler.build_secret(**parameters) })
      rescue Faraday::ServerError => e
        json_response = begin
          JSON.parse(e.response_body, symbolize_names: true)
        rescue
          {}
        end
        raise Hackler::JobError.from_json(json_response[:exception]) if json_response.key?(:exception)

        raise # reraise other unexpected errors
      end
    end
  end
end
