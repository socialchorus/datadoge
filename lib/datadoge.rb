require 'datadoge/version'
require 'gem_config'
require 'statsd'

module Datadoge
  include GemConfig::Base

  with_configuration do
    has :environments, classes: Array, default: ['production']
  end

  class Railtie < Rails::Railtie
    initializer "datadoge.configure_rails_initialization" do |app|
      $statsd = Statsd.new("localhost", 8125)

      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        controller = "#{event.payload[:controller]}"
        action = "action:#{event.payload[:action]}"
        format = "format:#{event.payload[:format] || 'all'}"
        format = "format:all" if format == "format:*/*"
        host = "host:#{ENV['INSTRUMENTATION_HOSTNAME']}"
        status = event.payload[:status]
        tags = [action, format, host]
        ActiveSupport::Notifications.instrument :performance, :controller => controller, :controller_action => event.payload[:action], :action => :timing, :tags => tags, :measurement => "response_time", :value => event.duration
        ActiveSupport::Notifications.instrument :performance, :controller => controller, :controller_action => event.payload[:action], :action => :timing, :tags => tags,  :measurement => "database.query.time", :value => event.payload[:db_runtime]
        ActiveSupport::Notifications.instrument :performance, :controller => controller, :controller_action => event.payload[:action], :tags => tags,  :measurement => "request.status.#{status}"
      end

      ActiveSupport::Notifications.subscribe(/performance/) do |name, start, finish, id, payload|
        send_event_to_statsd(name, payload) if Datadoge.configuration.environments.include?(Rails.env)
      end

      def send_event_to_statsd(name, payload)
        action = payload[:action] || :increment
        measurement = payload[:measurement]
        value = payload[:value]
        tags = payload[:tags]
        key_name = "app.#{ENV['app_name']}.#{payload[:controller]}.#{payload[:controller_action]}.#{measurement}"
        if action == :increment
          $statsd.increment key_name, :tags => tags
        else
          $statsd.histogram key_name, value, :tags => tags
        end
      end

    end
  end

end
