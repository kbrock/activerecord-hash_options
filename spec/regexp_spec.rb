require 'spec_helper'

RSpec.describe ActiveRecord::HashOptions::REGEXP do
  describe ".convert_regex" do
    # regex
    it "detects case insensitive regex" do
      expect(described_class.convert_regex(/a[a-z]*b/i)).to eq(["~", false, "a[a-z]*b"])
    end

    it "detects case sensitive regex" do
      expect(described_class.convert_regex(/a[a-z]*b/)).to eq(["~", true, "a[a-z]*b"])
    end

    it "detects incompatible wildcard" do
      expect(described_class.convert_regex(/a*/)).to eq(["~", true, "a*"])
    end

    it "detects incompattible period wildcard" do
      expect(described_class.convert_regex(/file[.]*txt/)).to eq(["~", true, "file[.]*txt"])
    end

    # like

    it "detects case sensative like" do
      expect(described_class.convert_regex(/ab/)).to eq(["like", true, "%ab%"])
    end

    it "detects case insensitive like" do
      expect(described_class.convert_regex(/ab/i)).to eq(["like", false, "%ab%"])
    end

    it "detects like left anchor" do
      expect(described_class.convert_regex(/^ab/)).to eq(["like", true, "ab%"])
    end

    it "detects like right anchor" do
      expect(described_class.convert_regex(/ab$/)).to eq(["like", true, "%ab"])
    end

    it "supports wildcard .* => %" do # stretch
      expect(described_class.convert_regex(/^this.*that$/)).to eq(["like", true, "this%that"])
    end

    it "supports single character wildcard . => _" do # stretch (bug)
      expect(described_class.convert_regex(/^this.that$/)).to eq(["like", true, "this_that"])
    end

    it "supports escaped period (\\.) to like" do
      expect(described_class.convert_regex(/file\.txt$/)).to eq(["like", true, "%file.txt"])
    end

    it "supports escaped period ([.]) to like" do
      expect(described_class.convert_regex(/file[.]txt$/)).to eq(["like", true, "%file.txt"])
    end

    it "supports escaped period (Regexp.escape)" do
      expect(described_class.convert_regex(/#{Regexp.escape("file.txt")}$/)).to eq(["like", true, "%file.txt"])
    end

    # equality

    it "detects equality" do
      expect(described_class.convert_regex(/^ab$/)).to eq(["=", true, "ab"])
    end

    it "detects case insensitive equality" do
      expect(described_class.convert_regex(/^ab$/i)).to eq(["=", false, "ab"])
    end

    it "detects escaped % ([%]) to equals" do
      expect(described_class.convert_regex(/^a[%]b$/)).to eq(["=", true, "a\\%b"])
    end

    it "detects escaped % (\\%) to equals" do
      expect(described_class.convert_regex(/^a\%b$/)).to eq(["=", true, "a\\%b"]) # rubocop:disable Style/RedundantRegexpEscape
    end

    it "detects escaped % ([%]) followed by wildcard " do
      expect(described_class.convert_regex(/^a[%]/)).to eq(["like", true, "a\\%%"])
    end

    it "detects escaped % ([%]) to equals" do
      expect(described_class.convert_regex(/^a\%b$/)).to eq(["=", true, "a\\%b"]) # rubocop:disable Style/RedundantRegexpEscape
    end
  end

  describe "#gen_sql" do
    # convert_regex only returns 3 modes: "~", "=", "like"
    # TBH/ only adding this for code coverage reasons
    it { expect { described_class.gen_sql("src", "bad mode", true, "dest") }.to raise_error(RuntimeError, /Unknown regular expression expansion.*/)}
  end
end
