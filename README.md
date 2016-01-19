# Datadoge

This gem is notified of basic performance metrics for a Rails application, and sends the measurements to DataDog.

Many thanks to [mm53bar](https://github.com/mm53bar) for the groundwork laid in [this gist](https://gist.github.com/mm53bar/4674071).

## Installation

Install the [Datadog Agent](https://app.datadoghq.com/account/settings#agent) on your application server. This gem only
works on servers which have the Datadog Agent installed.

Add this line to your application's Gemfile:

    gem 'datadoge', git: 'https://github.com/socialchorus/datadoge.git', branch: 'master'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datadoge

## Usage

By default, performance metrics are only reported to Datadog from production environments which have the
[Datadog agent](https://app.datadoghq.com/account/settings#agent) installed.

To enable Datadog reporting in non-production environments, add the following to an initializer:

    ENV['app_name'] = 'pony_express'
    ENV['INSTRUMENTATION_HOSTNAME'] = Socket.gethostname

    Datadoge.configure do |config|
      config.environments = ['staging', 'qa', 'production']
    end

This will enable Rails metrics for controllers and actions automatically.

For more fine grained metrics, you can use the Metrics class

    Datadoge::Metrics.time("#{self.class.name}.#{__method__.to_s}.time") do
      #do some interesting stuff.
    end

## Contributing

1. Fork it ( https://github.com/metova/datadoge/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
