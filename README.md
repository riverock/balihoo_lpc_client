[![Code Climate](https://codeclimate.com/github/riverock/balihoo_lpc_client/badges/gpa.svg)](https://codeclimate.com/github/riverock/balihoo_lpc_client)
[![Test Coverage](https://codeclimate.com/github/riverock/balihoo_lpc_client/badges/coverage.svg)](https://codeclimate.com/github/riverock/balihoo_lpc_client/coverage)
[![Build Status](https://travis-ci.org/riverock/balihoo_lpc_client.svg?branch=develop)](https://travis-ci.org/riverock/balihoo_lpc_client)

# BalihooLpcClient

This provides a ruby wrapper around the Balihoo Local Partner Connect API.

**NOTE: It is still under development and all the available endpoints have not yet been
implemented.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'balihoo_lpc_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install balihoo_lpc_client

## Usage

Using the gem is quite simple.

### Configuration

First we must create a Configuration object.

```ruby
opts = {
  brand_key: 'brand_key',
  api_key: 'api_key',
  location_key: 'location_key', # optional more below
  user_id: 'brand_key', # currently not used, Balihoo suggests setting same as brand_key
  group_id: 'brand_key' # currently not used, Balihoo suggests setting same as brand_key
}
config = BalihooLpcClient::Configuration.create(opts)
```

The `location_key` is an optional parameter. When not given the api will require
an array of locations to be passed to the api endpoints. This is explained
further below.

### Initialization

Once we have the config created we can use that to create an instance of the Api
object and authenticate with Balihoo.

```ruby
api = BalihooLpcClient::Api.new(config: config)
api.authenticate!
```

The `authenticate!` method will call out to Balihoo and set the `client_id` and
`client_api_key` on the config object for you.

```ruby
config.client_id # => <client_id from Balihoo>
config.client_api_key # => <client_api_key from Balihoo>
```

Once we have authenticated we can begin to call the various endpoints.

### Campaigns

If you passed a `location_key` to the config then you can simply call
`campaigns` on the api object.

```ruby
api.campaigns # => Array[BalihooLpcClient::Response::Campaign]
```

If the `location_key` was not passed then you must pass an array with a single
location to get campaigns for. _Passing multiple locations in the array is not
supported by the gem yet but is coming._

```ruby
api.campaigns({ locations: '1' }) # => Array[BalihooLpcClient::Response::Campaign]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/riverock/balihoo_lpc. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
