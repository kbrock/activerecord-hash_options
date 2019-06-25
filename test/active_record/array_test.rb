require 'test_helper'

class ActiveRecord::ArrayTest < Minitest::Test
  include ActiveRecord::HashOptions::Helpers

  def test_that_it_has_a_version_number
    refute_nil ::ActiveRecord::HashOptions::VERSION
  end

  def test_scope_gt
    skip("need to test on relations")
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.big_values, [big]
  end

  # number tests

  # gt available through include helpers (line 4)
  def test_gt
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:value => gt(10)), [big]
  end

  def test_lt
    Table1.destroy_all
    small = Table1.create(:name => "small", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:value => lt(10)), [small]
  end

  # like tests

  def test_ilike
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "Big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => ilike('%big%')), [big]
  end

  def test_ilike_case
    Table1.destroy_all
    big1 = Table1.create(:name => "Big", :value => 1)
    big2 = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => ilike('%big%')).sort_by(&:name), [big1, big2]
  end

  def test_like
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => like('%big%')), [big]
  end

  def test_not_like
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => not_like('%small%')), [big]
  end

  # postgres only


  def test_regexp
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => /^bi.*/), [big]
    assert_equal Table1.all.to_a.where(:name => /^BI.*/), []
    assert_equal Table1.all.to_a.where(:name => /^BI.*/i), [big]
  end


  # modified like entries

  def test_starts_with
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => starts_with('b')), [big]
  end

  def test_ends_with
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => ends_with('g')), [big]
  end

  def test_contains
    Table1.destroy_all
    Table1.create(:name => "small", :value => 1)
    big = Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => contains('i')), [big]
  end

  # compound tests

  def test_compound_ilike_case
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where(:name => ilike('%big%'), :value => lte(10)), [big]
  end

  def test_not_compound
    skip("where.not is not implemented yet for arrays")
    Table1.destroy_all
    big = Table1.create(:name => "Big", :value => 1)
    Table1.create(:name => "big", :value => 100)

    assert_equal Table1.all.to_a.where.not(:name => ilike('%small%'), :value => gte(10)), [big]
  end
end
