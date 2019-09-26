RSpec.describe ActiveRecord::HashOptions do
  before do
    Table1.destroy_all
  end
  let!(:small) { Table1.create(:name => "small", :value => 1) }
  let!(:big)   { Table1.create(:name => "big", :value => 10) }
  let!(:big2)  { Table1.create(:name => "BIG", :value => 100) }

  shared_examples "scope comparable" do
    it "supports scopes with comparisons" do
      expect(collection.big_values).to match_array([big2])
    end
  end

  shared_examples "numeric comparable" do
    it "compares with gt" do
      expect(filter(collection, :value => gt(10))).to eq([big2])
    end

    it "compares with lt" do
      expect(filter(collection, :value => lt(10))).to eq([small])
    end
  end

  shared_examples "string comparable" do

    # insensitivity

    it "compares with insensitivity" do
      expect(filter(collection, :name => insensitive('Big'))).to match_array([big, big2])
    end

    # like

    it "compares with ilike" do
      expect(filter(collection, :name => ilike('%big%'))).to match_array([big, big2])
    end

    it "compares with like" do
      if case_sensitive?
        expect(filter(collection, :name => like('%big%'))).to eq([big])
      else
        expect(filter(collection, :name => like('%big%'))).to eq([big, big2])
      end
    end

    it "compares with not_like" do
      expect(filter(collection, :name => not_like('%small%'))).to eq([big, big2])
    end

    # modified like entries

    it "compares with starts_with" do
      if case_sensitive?
        expect(filter(collection, :name => starts_with('b'))).to eq([big])
      else
        expect(filter(collection, :name => starts_with('b'))).to eq([big, big2])
      end
    end

    it "compares with ends_with" do
      if case_sensitive?
        expect(filter(collection, :name => ends_with('g'))).to eq([big])
      else
        expect(filter(collection, :name => ends_with('g'))).to eq([big, big2])
      end
    end

    it "compares with contains" do
      if case_sensitive?
        expect(filter(collection, :name => contains('i'))).to match_array([big])
      else
        expect(filter(collection, :name => contains('i'))).to match_array([big, big2])
      end
    end
  end

  shared_examples "regexp comparable" do
    it "compares with regexp" do
      skip("db does not support regexps") unless supports_regexp?

      expect(filter(collection, :name => /^bi.*/)).to eq([big])
      expect(filter(collection, :name => /^Bi.*/)).to eq([])
      expect(filter(collection, :name => /^Bi.*/i)).to eq([big, big2])
    end
  end

  shared_examples "compound comparable" do
    it "compares with compound_ilike_case" do
      expect(filter(collection, :name => ilike('%big%'), :value => lte(10))).to eq([big])
    end

    it "compares with not_compound" do
      expect(filter(collection, {:name => ilike('%small%'), :value => gte(10)}, false)).to eq([big])
    end
  end

  describe "Array" do
    let(:collection) { Table1.all.to_a }

    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
  end

  describe "Scope" do
    let(:collection) { Table1 }

    it_should_behave_like "scope comparable"
    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
  end

  def supports_regexp?
    array_test? || ENV["DB"] == "pg"
  end

  # sqlite is not case sensitive
  def case_sensitive?
    array_test?
  end

  def array_test?
    collection.kind_of?(Array)
  end

  def filter(collection, conditions, negate = false)
    ActiveRecord::HashOptions.filter(collection, conditions, negate)
  end
end
