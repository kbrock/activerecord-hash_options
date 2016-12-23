$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
Bundler.setup

require 'active_record'
require 'active_record/hash_options'
require 'minitest/autorun'

class MyTestDatabase
  def self.setup
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
  end
end

MyTestDatabase.setup
ActiveRecord::Migration.new.create_table :table1s do |t|
  t.string  :name
  t.integer :value
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
