RSpec.describe ActiveRecord::HashOptions do
  before do
    model.destroy_all
  end

  # for array, we override. but for db, just use the db class
  let(:model) { collection }

  let!(:small) { model.create(:name => "small", :value => 1) }
  let!(:big)   { model.create(:name => "big", :value => 10) }
  let!(:big2)  { model.create(:name => "BIG", :value => 100) }
  let!(:bad)   { model.create(:name => nil, :value => nil) }

  ########## scopes embedded in the model ##########

  shared_examples "scope comparable" do
    it "supports scopes with comparisons" do
      expect(collection.big_values).to match_array([big2])
    end

    it "supports scopes with like comparisons" do
      if case_sensitive_like?
        expect(collection.big_name).to match_array([big])
      else
        expect(collection.big_name).to match_array([big, big2])
      end
    end
  end

  ########## numeric comparisons ##########

  shared_examples "numeric comparable" do
    it "compares with gt" do
      expect(filter(collection, :value => gt(10))).to eq([big2])
    end

    it "compares with gt null" do
      expect(filter(collection, :value => gt(nil))).to be_empty
    end

    it "compares with gt (long)" do
      expect(filter(collection, :value => ActiveRecord::HashOptions::GT(10))).to eq([big2])
    end

    it "compares with gte" do
      expect(filter(collection, :value => gte(10))).to match_array([big, big2])
    end

    it "compares with gte null" do
      expect(filter(collection, :value => gte(nil))).to be_empty
    end

    it "compares with gte (long)" do
      expect(filter(collection, :value => ActiveRecord::HashOptions::GTE(10))).to match_array([big, big2])
    end

    it "compares with lt" do
      expect(filter(collection, :value => lt(10))).to eq([small])
    end

    it "compares with lt null" do
      expect(filter(collection, :value => lt(nil))).to be_empty
    end

    it "compares with lt (long)" do
      expect(filter(collection, :value => ActiveRecord::HashOptions::LT(10))).to eq([small])
    end

    it "compares with lte" do
      expect(filter(collection, :value => lte(10))).to match_array([small, big])
    end

    it "compares with lte null" do
      expect(filter(collection, :value => lte(nil))).to be_empty
    end

    it "compares with lte (long)" do
      expect(filter(collection, :value => ActiveRecord::HashOptions::LTE(10))).to match_array([small, big])
    end

    it "compares with range" do
      expect(filter(collection, :value => 5..100)).to match_array([big, big2])
      expect(filter(collection, :value => 5...100)).to eq([big])
    end

    it "compares with partial ranges (infinity)" do
      expect(filter(collection, :value => (-Float::INFINITY..50))).to eq([small, big])
      expect(filter(collection, :value => (5..Float::INFINITY))).to eq([big, big2])
    end

    # open ranges require ruby 2.6
    it "compares with partial ranges (open ranges)" do
      expect(filter(collection, :value => ..50)).to eq([small, big])
      expect(filter(collection, :value => 5..)).to eq([big, big2])
    end

    it "compares with null" do
      expect(filter(collection, :value => nil)).to eq([bad])
    end

    it "compares with multiple values" do
      expect(filter(collection, :value => [nil, 10])).to match_array([bad, big])
    end
  end

  ########## string comparisons ##########

  shared_examples "string comparable" do
    it "compares with =" do
      if case_sensitive?
        expect(filter(collection, :name => "big")).to eq([big])
      else
        expect(filter(collection, :name => "big")).to match_array([big, big2])
      end
    end

    it "compares with gt lower" do
      expect(filter(collection, :name => gt("big"))).to eq([small])
    end

    it "compares with gt upper" do
      if case_sensitive?
        expect(filter(collection, :name => gt("BIG"))).to match_array([small, big])
      else
        expect(filter(collection, :name => gt("BIG"))).to eq([small])
      end
    end

    it "compares with gte" do
      expect(filter(collection, :name => gte("small"))).to eq([small])
    end

    it "compares with lt" do
      expect(filter(collection, :name => lt("small"))).to match_array([big, big2])
    end

    it "compares with lte lower" do
      expect(filter(collection, :name => lte("big"))).to match_array([big, big2])
    end

    it "compares with lte upper" do
      if case_sensitive?
        expect(filter(collection, :name => lte("BIG"))).to match_array([big2])
      else
        expect(filter(collection, :name => lte("BIG"))).to match_array([big, big2])
      end
    end

    it "compares with range" do
      if case_sensitive?
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

    it "compares with insensitivity (like)" do
      skip "db does not support case insensitive like" unless case_insensitive_like?

      old_like, ActiveRecord::HashOptions.use_like_for_compare = ActiveRecord::HashOptions.use_like_for_compare, true

      expect(filter(collection, :name => insensitive('Big'))).to match_array([big, big2])
    ensure
      ActiveRecord::HashOptions.use_like_for_compare = old_like
    end

    it "compares with insensitivity (function)" do
      old_like, ActiveRecord::HashOptions.use_like_for_compare = ActiveRecord::HashOptions.use_like_for_compare, false

      expect(filter(collection, :name => insensitive('Big'))).to match_array([big, big2])
    ensure
      ActiveRecord::HashOptions.use_like_for_compare = old_like
    end

    it "compares with insensitivity (long)" do
      expect(filter(collection, :name => ActiveRecord::HashOptions::INSENSITIVE('Big'))).to match_array([big, big2])
    end

    it "compares with insensitivity nil" do
      expect(filter(collection, :name => insensitive(nil))).to eq([bad])
    end

    it "compares with ilike" do
      if case_insensitive_like?
        expect(filter(collection, :name => ilike('%big%'))).to match_array([big, big2])
      else
        expect(filter(collection, :name => ilike('%big%'))).to match_array([big])
      end
    end

    it "compares with ilike (long)" do
      if case_insensitive_like?
        expect(filter(collection, :name => ActiveRecord::HashOptions::ILIKE('%big%'))).to match_array([big, big2])
      else
        expect(filter(collection, :name => ActiveRecord::HashOptions::ILIKE('%big%'))).to match_array([big])
      end
    end

    it "compares with like" do
      if case_sensitive_like?
        expect(filter(collection, :name => like('%big%'))).to eq([big])
      else
        expect(filter(collection, :name => like('%big%'))).to match_array([big, big2])
      end
    end

    it "compares with like (long)" do
      if case_sensitive_like?
        expect(filter(collection, :name => ActiveRecord::HashOptions::LIKE('%big%'))).to eq([big])
      else
        expect(filter(collection, :name => ActiveRecord::HashOptions::LIKE('%big%'))).to match_array([big, big2])
      end
    end

    it "compares with not_like" do
      expect(filter(collection, :name => not_like('%small%'))).to match_array([big, big2])
    end

    it "compares with like (long)" do
      expect(filter(collection, :name => ActiveRecord::HashOptions::NOT_LIKE('%small%'))).to eq([big, big2])
    end

    it "compares with starts_with" do
      if case_sensitive_like?
        expect(filter(collection, :name => starts_with('b'))).to match_array([big])
      else
        expect(filter(collection, :name => starts_with('b'))).to match_array([big, big2])
      end
    end

    it "compares with ends_with" do
      if case_sensitive_like?
        expect(filter(collection, :name => ends_with('g'))).to eq([big])
      else
        expect(filter(collection, :name => ends_with('g'))).to match_array([big, big2])
      end
    end

    it "compares with contains" do
      if case_sensitive_like?
        expect(filter(collection, :name => contains('i'))).to match_array([big])
      else
        expect(filter(collection, :name => contains('i'))).to match_array([big, big2])
      end
    end
  end

  ########## string regular expressions ##########

  shared_examples "regexp comparable" do
    it "compares with regexp lowercase (like)" do
      if case_sensitive_like?
        expect(filter(collection, :name => /^bi.*/)).to eq([big])
      else
        expect(filter(collection, :name => /^bi.*/)).to match_array([big, big2])
      end
    end

    it "compares with regexp mixed case (like)" do
      if case_sensitive_like?
        expect(filter(collection, :name => /^Bi.*/)).to eq([])
      else
        expect(filter(collection, :name => /^Bi.*/)).to match_array([big, big2])
      end
    end

    it "compares with regexp case insensitive (ilike)" do
      if case_insensitive_like?
        expect(filter(collection, :name => /^Bi.*/i)).to match_array([big, big2])
      else
        expect(filter(collection, :name => /^Bi.*/i)).to match_array([])
      end
    end

    it "compares with regexp case sensitive" do
      skip("db does not support regexps") unless supports_regex?

      if case_sensitive?
        expect(filter(collection, :name => /^bi*g/)).to match_array([big])
      else
        expect(filter(collection, :name => /^bi*g/)).to match_array([big, big2])
      end
    end

    it "compares with regexp case ignore" do
      skip("db does not support regexps") unless supports_regex?

      expect(filter(collection, :name => /^(b|B)(i|I)(g|G)/)).to match_array([big, big2])
    end

    # this is academic - people won't use this interface
    it "compares with regexp case sensitive (long)" do
      skip("db does not support regexps") unless supports_regex?

      if case_sensitive?
        expect(filter(collection, :name => ActiveRecord::HashOptions::REGEXP.new(/^bi*g/))).to match_array([big])
      else
        expect(filter(collection, :name => ActiveRecord::HashOptions::REGEXP.new(/^bi*g/))).to match_array([big, big2])
      end
    end

    it "compares with regexp case insensitive" do
      skip("db does not support regexps") unless supports_regex?

      if case_insensitive_like?
        expect(filter(collection, :name => /^Bi*g/i)).to match_array([big, big2])
      else
        expect(filter(collection, :name => /^Bi*g/i)).to match_array([])
      end
    end

    it "compares with case sensitive (=)" do
      if case_sensitive?
        expect(filter(collection, :name => /^BIG$/)).to match_array([big2])
      else
        expect(filter(collection, :name => /^BIG$/)).to match_array([big, big2])
      end
    end

    it "compares with regexp case insensitive (=, like)" do
      skip "db does not support case insensitive like" unless case_insensitive_like?

      old_like, ActiveRecord::HashOptions.use_like_for_compare = ActiveRecord::HashOptions.use_like_for_compare, true

      expect(filter(collection, :name => /^Big$/i)).to match_array([big, big2])
    ensure
      ActiveRecord::HashOptions.use_like_for_compare = old_like
    end

    it "compares with insensitivity (=, function)" do
      old_like, ActiveRecord::HashOptions.use_like_for_compare = ActiveRecord::HashOptions.use_like_for_compare, false

      expect(filter(collection, :name => /^Big$/i)).to match_array([big, big2])
    ensure
      ActiveRecord::HashOptions.use_like_for_compare = old_like
    end

    it "compares with insensitivity (=, function) and punctuation" do
      # specifically testing the slash in query that resolves to a function
      old_like, ActiveRecord::HashOptions.use_like_for_compare = ActiveRecord::HashOptions.use_like_for_compare, false

      punctuation = model.create(:name => 'big%data')
      expect(filter(collection, :name => /^big\%data$/i)).to match_array([punctuation])
    ensure
      ActiveRecord::HashOptions.use_like_for_compare = old_like
    end
  end

  ########## compound expressions ##########

  shared_examples "compound comparable" do
    it "compares with compound_ilike_case" do
      expect(filter(collection, :name => ilike('%big%'), :value => lte(10))).to eq([big])
    end

    it "compares with not_compound" do
      # rails >=6.1 logic:
      # ! (name = small && value >= 100) --> name != small || value > 10
      expect(filter(collection, {:name => ilike('%small%'), :value => lte(10)}, true)).to eq([big, big2])
    end
  end

  ############################## Base tests ##############################

  describe "Array" do
    let(:model) { Table1 }
    let(:collection) { Table1.all.to_a }

    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
    it_should_behave_like "compound comparable"
  end

  describe "Scope database" do
    let(:collection) { Table1 }

    it_should_behave_like "scope comparable"
    it_should_behave_like "numeric comparable"
    it_should_behave_like "string comparable"
    it_should_behave_like "regexp comparable"
    it_should_behave_like "compound comparable"
  end

  describe "Child database table" do
    let(:collection) { TableC }

    # could do them all, but just checking one for now
    it_should_behave_like "string comparable"
  end

  private

  def case_insensitive_like?
    array_test? || ActiveRecord::HashOptions.insensitive_like
  end

  def case_sensitive_like?
    array_test? || ActiveRecord::HashOptions.sensitive_like
  end

  def case_sensitive?
    array_test? || ActiveRecord::HashOptions.sensitive_compare
  end

  def supports_regex?
    array_test? || ActiveRecord::HashOptions.use_regex
  end

  def array_test?
    collection.kind_of?(Array)
  end

  # filter a collection
  # this is typically called via:
  #   ActiveRecord::HashOptions.filter(collection, conditions, negate)
  # although there are many ways to reduce the typing - see the readme.
  def filter(collection, conditions, negate = false) # rubocop:disable Style/OptionalBooleanParameter
    ActiveRecord::HashOptions.filter(collection, conditions, negate)
  end
end
