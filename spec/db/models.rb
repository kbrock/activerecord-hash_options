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
end

# test inheritance
class TableC < Table1
end

# don't do this
# do Array.send(:include, ActiveRecord::HashOptions::Enumerable)
# I wanted to not corrupt array so I did this
class TestArray < Array
  include ActiveRecord::HashOptions::Enumerable

  def initialize(values)
    super()

    values.each { |val| self << val }
  end
end

class ArbitraryClass
  include ActiveRecord::HashOptions::Enumerable

  def initialize(values)
    @array = []
    values.each { |val| self << val }
  end

  def <<(value)
    @array << value
  end

  def select(&block)
    @array.select(&block)
  end
end
