# ActiveRecord::HashOptions

## Stalled

This is stalled because it is too hard to implement string comparisions that are the same in the database and in sql.
The solution will probably be simple but needs to be done. Definintely need to use the same locale for ruby as we are using in the database.

## What is it?

This enhances active record so that it can be used in more cases
than the pure equality case.

### Equality only

Active record hash syntax only support equality.
For things like case insensitivity or regular expression matching, arel is needed.

It would be nice to use `where(:col => val)` syntax for other operators, too.

### Problem 2

Active record caches data in an association. When a similar association has a where clause, it also needs to be downloaded since the `where()` clause is only executable in the database.

has_many :books
has_many :overdue_books, -> { where(:overdue => true) }

It would be nice to only have 1 copy of the data locally.

### Problem 3

Active record only supports sorting case sensitive.

It would be nice to use standard `order()`

### Problem 4

The user needs to search and provide custom query logic.

### Result

Hash Options handles the first use case but has grand aspirations to handle all 4.

Thanks to the example from [codesnik](https://gist.github.com/codesnik/2ebba1940c05b08b17f9)


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


## A note about `nil` vs `null`.

Sql uses `null` to represent unknown, ruby uses `nil` to represent no value. These are
similar. Unfortunatly sql and ruby handle comparisons with these values differently.

In ruby, you can compare a value with `nil`. `x != nil` is true and `nil == nil` is true
In sql you can not. `x <> null` and `null = null` are both false. Instead, sql has
a special operator, `IS NULL`. `x IS NOT NULL` and `null IS NULL` are both true.
This causes ruby and sql logic to deviate a little.

ActiveRecord takes the ruby definition of equality and translates `where(:x => nil)`
to be `x IS NULL` and not literally `x == NULL`. Please note, this also means a `null`
in a column is handle differently from a `null` in a literal comparison clause.

The implications can be seen by comparing ruby, sql, and active record of the same logic.
The ruby expression is shown, but is easily converted to the other forms:

language      | expression | negation
--------------|------------|---------
ruby          | `col == "x"`|`col != "x"`
sql           | `WHERE col == "x"`|`WHERE col <> "x"`
active record | `Model.where(:col => "x")`| `Model.where.not(:col => "x")`
arel          | `Model.arel_table[:col].eq("x")`|`Model.arel_table[:col].neq("x")`
hash_options  | [].where(:col => "x")| [].where.not(:col => "x")

Arel, Active Record, and Hash Options all follow the same logic

expression  |col value| ruby | sql    | Active Record
------------|---------|------|----    |-----
col == 'x'  | "x"     | true | true   | true
col != 'x'  | "x"     | false| false  | false
col == nil  | "x"     | false| false  | false (treated as IS NULL)
col != nil  | "x"     | true | **false**| true (treated as IS NOT NULL)
col == nil  | nil     | true | **false**| true (treated as IS NULL)
col != nil  | nil     | false| false  | false (treated as IS NOT NULL)
col IS NULL | nil     | n/a  | true   | n/a (merged with the == nil case)
col == 'x'  | nil     | false| false  | false (NOTE: these are not treated as IS NULL)
col != 'x'  | nil     | true | **false**| **false**
!(col =='x')| nil     | true | true   | true
!(col !='x')| nil     | false| **true** | **true**
!(col ==nil)| "x"     | true | true   | true (treated as IS NULL)
!(col !=nil)| "x"     | false| **true** | false? (treated as IS NULL)
col1 == col2| nil,nil | true | **false**| **false** (no translation occurs)

So note, in active record, the following nuances occur for the `null` edge case, especially
around inequality. It stems around a null literal is treated differentaly than a null in a
column.

Comunicative property does not work: `nil != 'x'` has a different value from `'x' != nil`.
Distributive property does not work: `nil != 'x'` has a different value from `!(x == nil)`.
Also note, the in the column to column case, this is not always what the user intended.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-hash_options'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-hash_options


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment. This runs against sqlite and has the `Author`, `Book`, `Bookmark`, and `Photo` models
avaiable for your convenience.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kbrock/activerecord-hash_options.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

