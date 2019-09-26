$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
Bundler.setup

require 'active_record'
require 'active_record/hash_options'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # not optimal, but all tests can use the ':column => gt()' syntax
  config.include ActiveRecord::HashOptions::Helpers

  #config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end

Dir["./spec/support/**/*.rb"].each {|f| require f}


class MyTestDatabase
  def self.setup
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
  end
end

MyTestDatabase.setup
ActiveRecord::Migration.new.create_table :table1s do |t|
  t.string  :name
  t.integer :value, :null => true
end

class Table1 < ActiveRecord::Base
  extend ActiveRecord::HashOptions
  include ActiveRecord::HashOptions::Helpers
  extend ActiveRecord::HashOptions::Helpers

  def self.big_values
    where(:value => gt(10))
  end

  def self.big_name
    where(:name => like("%big%"))
  end

  def self.big_iname
    where(:name => ilike("%big%"))
  end
end

