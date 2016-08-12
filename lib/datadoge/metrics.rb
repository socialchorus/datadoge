require 'statsd'

module Datadoge
  class Metrics

    def self.increment(event)
      statsd.increment("#{prefix}.#{event}")
    end

    def self.time(event)
      statsd.time("#{prefix}.#{event}") do
        yield
      end
    end

    def self.prefix
      "app.#{ENV['app_name']}"
    end

    def self.statsd
      @statsd ||= Statsd.new("localhost", 8125)
    end
  end
end
