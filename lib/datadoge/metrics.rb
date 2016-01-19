require 'statsd'

module Datadoge
  class Metrics

    EVENT_BASE_NAME = "app.#{ENV['app_name']}"

    def self.increment(event)
      statsd.increment("#{EVENT_BASE_NAME}.#{event}")
    end

    def self.time(event)
      statsd.time("#{EVENT_BASE_NAME}.#{event}") do
        yield
      end
    end

    def self.statsd
      Statsd.new("localhost", 8125)
    end
  end
end
