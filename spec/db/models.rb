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
