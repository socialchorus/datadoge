module Datadoge

  # A handy super class for doing typical measurements from a ActiveSupport::Notifications
  # subscriber
  class NotificationSubscriber
    def ms(start, finish)
      ((finish - start) * 1000).to_i
    end

    def compile_tags(hsh={})
      hsh.map { |k, v| "#{k}:#{v}" }
    end

    delegate :timing, :gauge, :count, :increment, to: Datadoge::Metrics

    def self.subscribe_to(name)
      ActiveSupport::Notifications.subscribe(name, new)
    end
  end

end
