require 'spec_helper'

RSpec.describe ActiveRecord::HashOptions::Enumerable do
  let(:small) { Table1.new(:name => "small", :value => 1) }
  let(:big)   { Table1.new(:name => "big", :value => 10) }
  let(:big2)  { Table1.new(:name => "BIG", :value => 100) }
  let(:bad)   { Table1.new(:name => nil, :value => nil) }

  let(:array) do
    ArbitraryClass.new([small, big, big2, bad])
  end

  let(:arbitrary) do
    ArbitraryClass.new([small, big, big2, bad])
  end

  context "with array base class" do
    describe "#where" do
      it "filters" do
        expect(array.where(:name => "big")).to eq([big])
      end

      it "filters (is null)" do
        expect(array.where(:name => ["big", nil])).to eq([big, bad])
      end

      it "negates" do
        expect(array.where.not(:name => %w[big BIG nil])).to eq([small])
      end
    end
  end

  context "with non AR class" do
    describe "#where" do
      it "filters" do
        expect(arbitrary.where(:name => "big")).to eq([big])
      end

      it "filters (is null)" do
        expect(arbitrary.where(:name => ["big", nil])).to eq([big, bad])
      end

      it "negates" do
        expect(arbitrary.where.not(:name => %w[big BIG nil])).to eq([small])
      end
    end
  end
end
