require 'datadog/statsd'

module Datadoge
  # A wrapper for a Datadog::Statsd instance with proper prefixes applied.
  class Metrics
    def self.prefix
      "app.#{ENV['APP_NAME']}"
    end

    def self.statsd
      @statsd ||= Datadog::Statsd.new("localhost", 8125, namespace: self.prefix)
    end

    class << self
      delegate :increment, :decrement, :count, :gauge, :histogram, :timing, :time, :set,
        :service_check, :event, :batch, to: :statsd
    end
  end
end
