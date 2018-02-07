require 'test_helper'

class ActiveRecord::HashOptionsTest < Minitest::Test
  include ActiveRecord::HashOptions::Helpers

  def test_that_it_has_a_version_number
    refute_nil ::ActiveRecord::HashOptions::VERSION
  end

  def test_scope_gt
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.big_values, [big]
  end

  # gt available through include helpers
  def test_gt
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:value => gt(10)), [big]
  end

  def test_gt
    Table1.destroy_all
    small = Table1.create(:name => "small", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:value => lt(10)), [small]
  end

  def test_ilike
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "Big", :value => 100)

    assert_equal Table1.where(:name => ilike('%big%')), [big]
  end

  def test_ilike_case
    Table1.destroy_all
    big1 = Table1.create(:name => "Big", :value => 1)
    big2 = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:name => ilike('%big%')).order(:name), [big1, big2]
  end

  def test_like
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:name => like('%big%')), [big]
  end

  def test_not_like
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:name => not_like('%small%')), [big]
  end

  def test_compound_ilike_case
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where(:name => ilike('%big%'), :value => lte(10)), [big]
  end

  def test_not_compound
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.where.not(:name => ilike('%small%'), :value => gte(10)), [big]
  end
end
