# SensitiveDataFilter

A Rack Middleware level Rails filter for sensitive data

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sensitive_data_filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sensitive_data_filter

## Usage

### Enable the middleware

E.g. for Rails, add the following in application.rb

```ruby
# --- Sensitive Data Filtering ---
config.middleware.use SensitiveDataFilter::Middleware::Filter
```

### Configuration

```ruby
SensitiveDataFilter.config do |config|
  config.enable_types :credit_card # Already defaults to :credit_card if not specified
  config.on_occurrence do |occurrence| 
    # Report occurrence
  end 
end
```

An occurrence object has the following properties:

* origin_ip:       the IP address that originated the request
* request_method:  the HTTP method for the request (GET, POST, etc.)
* url:             the URL of the request
* original_params: the parameters sent with the request
* filtered_params: the parameters sent with the request, with sensitive data filtered
* session:         the session properties for the request
* matches:         the matched sensitive data
* matches_count:   the number of matches per data type, e.g. { 'CreditCard' => 1 }

It also exposes `to_h` and `to_s` methods for hash and string representation respectively.  
Please note that these representations omit sensitive data, i.e. `original_params` and `matches` are not included.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sealink/sensitive_data_filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

