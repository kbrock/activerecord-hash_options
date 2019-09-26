RSpec.describe ActiveRecord::HashOptions do
  before { Table1.destroy_all }

  shared_examples "scope comparable" do
    it "supports scopes with comparisons" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(collection.big_values).to eq([big])
    end
  end

  shared_examples "numeric comparable" do
    it "compares with gt" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :value => gt(10))).to eq([big])
    end

    it "compares with lt" do
      small = Table1.create(:name => "small", :value => 1)
      Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :value => lt(10))).to eq([small])
    end
  end

  shared_examples "string comparable" do

    # insensitivity

    it "compares with insensitivity" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 2)
      big2 = Table1.create(:name => "BIG", :value => 100)

      expect(filter(collection, :name => insensitive('Big'))).to match_array([big, big2])
    end

    # like

    it "compares with ilike" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "Big", :value => 100)

      expect(filter(collection, :name => ilike('%big%'))).to eq([big])
    end

    it "compares with ilike_case" do
      big1 = Table1.create(:name => "Big", :value => 1)
      big2 = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => ilike('%big%'))).to match_array([big1, big2])
    end

    it "compares with like" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => like('%big%'))).to eq([big])
    end

    it "compares with not_like" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => not_like('%small%'))).to eq([big])
    end

    # modified like entries

    it "compares with starts_with" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => starts_with('b'))).to eq([big])
    end

    it "compares with ends_with" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => ends_with('g'))).to eq([big])
    end

    it "compares with contains" do
      Table1.create(:name => "small", :value => 1)
      big = Table1.create(:name => "big", :value => 100)

      expect(filter(collection, :name => contains('i'))).to eq([big])
    end
  end

  describe "Array" do
    let(:collection) { Table1.all.to_a }
    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
  end

  describe "Scope" do
    let(:collection) { Table1 }

    it_should_behave_like "scope comparable"
    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
  end

  def filter(collection, conditions, negate = false)
    ActiveRecord::HashOptions.filter(collection, conditions, negate)
  end
end
