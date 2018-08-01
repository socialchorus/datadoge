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

```ruby
ENV['app_name'] = 'pony_express'
ENV['INSTRUMENTATION_HOSTNAME'] = Socket.gethostname
ENV['INSTRUMENTATION_PORT'] = 8001 #optional, default is 8125

Datadoge.configure do |config|
  config.environments = ['staging', 'qa', 'production']
end
```

This will enable Rails metrics for controllers and actions automatically.

For custom metrics, you can use the Metrics class

```ruby
Datadoge::Metrics.time("something.measured.time") do
  #do some interesting stuff.
end
```

Or to use use directly with ActiveSupport::Notifications, build a class:

```ruby
class SomeSubscriber < Datadoge::NotificationSubscriber
  subscribe_to 'perform.job.some_worker'

  def call(name, start, finish, unique_id, payload)
    # Compiles the k/v pairs into the correct format used by statsd
    tags = compile_tags payload.slice(:program_id, :category)

    # Timing performance for the job
    timing "some_worker.job.performance", ms(start, finish), tags: tags
    # Count how many times the job is performed
    increment 'some_worker.job.perform', tags: tags
  end
end
```

see lib/datadoge/notification_subscriber.rb for more.


## Contributing

1. Fork it ( https://github.com/metova/datadoge/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
