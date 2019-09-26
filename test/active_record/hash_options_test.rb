require 'test_helper'

class ActiveRecord::HashOptionsTest < Minitest::Test
  include ActiveRecord::HashOptions::Helpers

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
