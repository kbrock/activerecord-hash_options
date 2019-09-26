require 'test_helper'

class ActiveRecord::ArrayTest < Minitest::Test
  include ActiveRecord::HashOptions::Helpers
  # postgres only


  def test_regexp
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal filter(Table1.all, :name => /^bi.*/), [big]
    assert_equal filter(Table1.all, :name => /^BI.*/), []
    assert_equal filter(Table1.all, :name => /^BI.*/i), [big]
  end

  # compound tests

  def test_compound_ilike_case
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal filter(Table1.all, :name => ilike('%big%'), :value => lte(10)), [big]
  end

  def test_not_compound
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal filter(Table1.all, {:name => ilike('%small%'), :value => gte(10)}, true), [big]
  end

  private

  def filter(array, conditions, negate = false)
    ActiveRecord::HashOptions.filter(array.to_a, conditions, negate)
  end
end
