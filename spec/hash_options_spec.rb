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

  describe "Array" do
    let(:collection) { Table1.all.to_a }
    it_should_behave_like "numeric comparable"
  end

  describe "Scope" do
    let(:collection) { Table1 }

    it_should_behave_like "scope comparable"
    it_should_behave_like "numeric comparable"
  end

  def filter(collection, conditions, negate = false)
    ActiveRecord::HashOptions.filter(collection, conditions, negate)
  end
end
