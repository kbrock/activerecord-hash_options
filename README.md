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

There are a number of ways to use active record hash options, contingent upon how much 
you want to monkey patch your environment.

```ruby
require 'active_record/hash_options'

Person.where(:name => ActiveRecord::HashOptions::LIKE('Smith%'))
Person.where(:age => ActiveRecord::HashOptions::GTE(21))
```

---

```ruby
require 'active_record/hash_options'
include ActiveRecord::HashOptions

Person.where(:name => LIKE('Smith%'))
Person.where.not(:age => GTE(21))

ActiveRecord::HashOptions.filter(Person.all, :name => LIKE('Smith%'))
ActiveRecord::HashOptions.filter(Person.all.to_a, :name => LIKE('Smith%'))
ActiveRecord::HashOptions.filter(Person.all.to_a, :age => GTE(21), true)
```

---

```ruby
require 'active_record/hash_options'
include ActiveRecord::HashOptions::Helpers

Person.where(:name => like('Smith%'))
Person.where.not(:age => gte(21))

ActiveRecord::HashOptions.filter(Person.all.to_a, :name => like('Smith%'))
```

---

```ruby
require 'active_record/hash_options'
include ActiveRecord::HashOptions::Helpers
Array.send(:include, ActiveRecord::HashOptions::Enumerable)

Person.all.to_a.where(:name => like('Smith%'))
Person.all.to_a.where.not(:age => gte(21))

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment. Model `Table1` will be available
for your convenience

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kbrock/activerecord-hash_options.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

