# ActiveRecord::HashOptions

This extends the hash options passed into ActiveRecord `where`.

Thanks to the example from [codesnik](https://gist.github.com/codesnik/2ebba1940c05b08b17f9)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-hash_options'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-hash_options

## Usage

```ruby
Person.where(:name => like('Smith%'))

Person.where(:age => gte(21))
```

The operations also work with arrays

```ruby
Person.all.to_a.where(:name => like('Smith%'))

Person.all.to_a.where(:age => gte(21))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kbrock/activerecord-hash_options.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

