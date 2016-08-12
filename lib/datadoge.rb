require 'datadoge/version'
require 'datadoge/reporter'
require 'datadoge/metrics'
require 'gem_config'

module Datadoge
  include GemConfig::Base
  
  with_configuration do
    has :environments, classes: Array, default: ['production']
  end
  
  class Railtie < Rails::Railtie
    initializer 'datadoge.configure_rails_initialization' do |app|
      reporter = Reporter.new
      ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        reporter.report(event)
      end
    end
  end
end
