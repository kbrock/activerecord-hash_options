Array.send(:include, ActiveRecord::HashOptions::Enumerable)

RSpec.describe ActiveRecord::HashOptions do
  before do
    Table1.destroy_all
  end
  let!(:small) { Table1.create(:name => "small", :value => 1) }
  let!(:big)   { Table1.create(:name => "big", :value => 10) }
  let!(:big2)  { Table1.create(:name => "BIG", :value => 100) }
  let!(:bad)   { Table1.create(:name => nil, :value => nil) }

  ########## scopes embedded in the model ##########

  shared_examples "scope comparable" do
    it "supports scopes with comparisons" do
      expect(collection.big_values).to match_array([big2])
    end
  end

  ########## numeric comparisons ##########

  shared_examples "numeric comparable" do
    it "compares with gt" do
      expect(filter(collection, :value => gt(10))).to eq([big2])
    end

    it "compares with gte" do
      expect(filter(collection, :value => gte(10))).to match_array([big, big2])
    end

    it "compares with lt" do
      expect(filter(collection, :value => lt(10))).to eq([small])
    end

    it "compares with lte" do
      expect(filter(collection, :value => lte(10))).to match_array([small, big])
    end

    it "compares with range" do
      expect(filter(collection, :value => 5..100)).to match_array([big, big2])
      expect(filter(collection, :value => 5...100)).to eq([big])
    end

    it "compares with null" do
      expect(filter(collection, :value => nil)).to eq([bad])
    end
  end

  ########## string comparisons ##########

  shared_examples "string comparable" do
    it "compares with gt" do
      if !mac? && pg?
        expect(filter(collection, :name => gt("big"))).to match_array([small, big2])
      else
        expect(filter(collection, :name => gt("big"))).to eq([small])
      end
    end

    it "compares with gte" do
      expect(filter(collection, :name => gte("small"))).to eq([small])
    end

    it "compares with lt" do
      expect(filter(collection, :name => lt("small"))).to match_array([big, big2])
    end

    it "compares with lte" do
      if !mac? && pg?
        expect(filter(collection, :name => lte("big"))).to eq([big])
      else
        expect(filter(collection, :name => lte("big"))).to match_array([big, big2])
      end
    end

    it "compares with range" do
      if array_test? || (pg? && mac?) || sqlite?
        expect(filter(collection, :name => "big"..."small")).to eq([big])
        expect(filter(collection, :name => "big".."small")).to match_array([big, small])
      else
        expect(filter(collection, :name => "big"..."small")).to match_array([big, big2])
        expect(filter(collection, :name => "big".."small")).to match_array([big, big2, small])
      end
    end

    it "compares with null" do
      expect(filter(collection, :name => nil)).to eq([bad])
    end

    it "compares with insensitivity" do
      expect(filter(collection, :name => insensitive('Big'))).to match_array([big, big2])
    end

    it "compares with ilike" do
      expect(filter(collection, :name => ilike('%big%'))).to match_array([big, big2])
    end

    it "compares with like" do
      if array_test? || pg?
        expect(filter(collection, :name => like('%big%'))).to eq([big])
      else
        expect(filter(collection, :name => like('%big%'))).to match_array([big, big2])
      end
    end

    it "compares with not_like" do
      expect(filter(collection, :name => not_like('%small%'))).to match_array([big, big2])
    end

    it "compares with starts_with" do
      if array_test? || pg?
        expect(filter(collection, :name => starts_with('b'))).to match_array([big])
      else
        expect(filter(collection, :name => starts_with('b'))).to match_array([big, big2])
      end
    end

    it "compares with ends_with" do
      if array_test? || pg?
        expect(filter(collection, :name => ends_with('g'))).to eq([big])
      else
        expect(filter(collection, :name => ends_with('g'))).to match_array([big, big2])
      end
    end

    it "compares with contains" do
      if array_test? || pg?
        expect(filter(collection, :name => contains('i'))).to match_array([big])
      else
        expect(filter(collection, :name => contains('i'))).to match_array([big, big2])
      end
    end
  end

  ########## string regular expressions ##########

  shared_examples "regexp comparable" do
    it "compares with regexp" do
      skip("db #{ENV["db"]} does not support regexps") unless array_test? || pg?

      expect(filter(collection, :name => /^bi.*/)).to eq([big])
      expect(filter(collection, :name => /^Bi.*/)).to eq([])
      expect(filter(collection, :name => /^Bi.*/i)).to eq([big, big2])
    end
  end

  ########## compound expressions ##########

  shared_examples "compound comparable" do
    it "compares with compound_ilike_case" do
      expect(filter(collection, :name => ilike('%big%'), :value => lte(10))).to eq([big])
    end

    it "compares with not_compound" do
      # ! (name = small && value >= 100) --> name != small || value > 10
      expect(filter(collection, {:name => ilike('%small%'), :value => lte(10)}, true)).to eq([big2])
    end
  end


  ############################## Base tests ##############################

  describe "Array" do
    let(:collection) { Table1.all.to_a }

    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
    it_should_behave_like "compound comparable"
  end

  describe "Scope" do
    let(:collection) { Table1 }

    it_should_behave_like "scope comparable"
    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
    it_should_behave_like "compound comparable"
  end

  private

  def mac?
    Gem::Platform.local.os == "darwin"
  end

  def array_test?
    collection.kind_of?(Array)
  end

  def pg?
    (ENV["DB"] == "pg" && !array_test?)
  end

  def sqlite?
    ENV["DB"] == "sqlite3" && !array_test?
  end

  def filter(collection, conditions, negate = false)
    # ActiveRecord::HashOptions.filter(collection, conditions, negate)
    if negate
      collection.where.not(conditions)
    else
      collection.where(conditions)
    end
  end
end
