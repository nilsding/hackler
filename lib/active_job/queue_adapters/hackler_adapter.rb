# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class HacklerAdapter < AbstractAdapter
      def enqueue(job)
        j = Hackler::Job.create(data: JSON.dump(job.serialize))
        notify_worker(j)
      end

      def enqueue_at(job, timestamp)
        j = Hackler::Job.create(data: JSON.dump(job.serialize))
        notify_worker(j, timestamp)
      end

      private

      def notify_worker(job, timestamp = nil)
        conn = Hackler.connection_for(Hackler.worker_base_url)
        parameters = {
          id:        job.id,
          base_url:  Hackler.web_base_url,
          timestamp:,
        }
        conn.post("enqueue", parameters, { "x-hackler-secret" => Hackler.build_secret(**parameters) })
      end
    end
  end
end
