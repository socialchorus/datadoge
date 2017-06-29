require 'datadoge/version'
require 'datadoge/metrics'
require 'gem_config'

module Datadoge
  include GemConfig::Base

  with_configuration do
    has :environments, classes: Array, default: ['production']
  end
end

if defined?(Rails)
  require 'datadoge/railtie'
end
