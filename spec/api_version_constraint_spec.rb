require 'spec_helper.rb'

describe Stitches::ApiVersionConstraint do
  let(:version) { 2 }
  let(:request) { double("request", headers: headers) }

  subject(:constraint) { described_class.new(version) }

  context "no accept header" do
    let(:headers) { {} }
    it "doesn't match" do
      expect(constraint.matches?(request)).to eq(false)
    end
  end
  context "accept header missing version" do
    let(:headers) { { accept: "application/json" } }
    it "doesn't match" do
      expect(constraint.matches?(request)).to eq(false)
    end
  end
  context "accept header has wrong version" do
    let(:headers) { { accept: "application/json; version=1" } }
    it "doesn't match" do
      expect(constraint.matches?(request)).to eq(false)
    end
  end
  context "accept header has correct version" do
    let(:headers) { { accept: "application/json; version=2" } }
    it "matcheds" do
      expect(constraint.matches?(request)).to eq(true)
    end
  end
end
