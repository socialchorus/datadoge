require 'statsd'

module Datadoge
  class Reporter
    def initialize
      @statsd = Statsd.new('localhost', 8125)
    end

    def report(event)
      stats = Stats.new(event)
      send_histogram("response.time", stats, event.duration)
      send_histogram("database.query.time", stats, event.payload[:db_runtime])
      send_increment("request.status.#{event.payload[:status]}", stats)
    end

    private
    attr_reader :statsd

    def send_histogram(measurement, stats, value)
      statsd.histogram(stats.id(measurement), value, tags: stats.tags)
    end

    def send_increment(measurement, stats)
      statsd.increment(stats.id(measurement), tags: stats.tags)
    end

    class Stats
      attr_reader :tags

      def initialize(event)
        payload = event.payload
        controller = payload[:controller]
        action = payload[:action]
        format = payload[:format]
        app_name = ENV['APP_NAME']
        host = ENV['INSTRUMENTATION_HOSTNAME']
        @id_prefix = "app.#{app_name}.#{controller}.#{action}"
        @tags = ["action:#{action}", "format:#{format}", "host:#{host}"]
      end

      def id(measurement)
        "#{@id_prefix}.#{measurement}"
      end
    end
  end
end
