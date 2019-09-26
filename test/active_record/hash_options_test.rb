require 'test_helper'

class ActiveRecord::HashOptionsTest < Minitest::Test
  include ActiveRecord::HashOptions::Helpers

  # postgres only


  def test_regexp
    skip "sqlite has no db support for regexp"
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => /^bi.*/), [big]
    assert_equal Table1.all.to_a.where(:name => /^BI.*/), []
    assert_equal Table1.all.to_a.where(:name => /^BI.*/i), [big]
  end

  # compound tests

  def test_compound_ilike_case_direct
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:name => ilike('%big%'), :value => lte(10)), [big]
  end

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

    assert_equal Table1.where.not(:name => ilike('%small%'), :value => gte(10)), [big]
  end

  private

  def filter(scope, conditions)
    ActiveRecord::HashOptions.filter(scope, conditions)
  end
end
