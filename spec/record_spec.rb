# frozen_string_literal: true

RSpec.describe Ayashige::Record do
  subject { Ayashige::Record.new(updated: "2018/01/01", domain_name: "test.com") }

  describe "#updated_on" do
    context "when given a valid date" do
      it "should return %Y-%m-%d format string" do
        s = subject.send(:normalize_date, "2018/01/01")
        expect(s).to eq("2018-01-01")
      end
    end
    context "when given an invalid date" do
      it "should raise an ArgumentError" do
        expect { subject.send(:normalize_date, "invalid") }.to raise_error(ArgumentError)
      end
    end
  end
end
