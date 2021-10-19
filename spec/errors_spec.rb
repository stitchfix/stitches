require 'rails_helper'

class MyFakeError < StandardError
end

class FakePersonHolder
  include ActiveModel::Validations
  attr_accessor :name, :person

  validates_presence_of :name

  def valid?
    # doing this because we can't use validates_associated on a non-AR object, and
    # our logic doesn't depend on validates_associated, per se
    super.tap {
      unless person.valid?
        errors.add(:person,"is not valid")
      end
    }
  end
end

class FakePerson
  include ActiveModel::Validations

  attr_accessor :first_name, :last_name, :age

  validates_each :first_name, :last_name do |record, attr, value|
    record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
  end

  validates_numericality_of :age
  validates_presence_of :first_name
end

describe Stitches::Errors do
  it "can be created from an exception" do
    exception = MyFakeError.new("OH NOES!")
    errors    = Stitches::Errors.from_exception(exception)

    expect(errors.size).to eq(1)
    expect(errors.first.code).to eq("my_fake")
    expect(errors.first.message).to eq("OH NOES!")
  end

  it "renders useful JSON" do
    errors = Stitches::Errors.new([
      Stitches::Error.new(code: "not_found", message: "Was not found, yo"),
      Stitches::Error.new(code: "and_you_should_feel_bad", message: "And you should feel bad about even asking"),
    ])

    expect(errors.to_json).to eq(
      [
        {
          "code" => "not_found",
          "message" => "Was not found, yo",
        },
        {
          "code" => "and_you_should_feel_bad",
          "message" => "And you should feel bad about even asking",
        }
      ].to_json
    )
  end

  context "creation from an active record object" do
    let(:object) { FakePerson.new.tap { |person|
      person.age = "asdfasdf"
      person.last_name = "zjohnson"
    }}
    it "sets reasonable messages for the fields of the object" do
      object.valid?
      errors = Stitches::Errors.from_active_record_object(object)
      errors_hash = JSON.parse(errors.to_json).sort_by {|_| _["code"] }
      expect(errors_hash[0]["code"]).to eq("age_invalid")
      expect(errors_hash[0]["message"]).to eq("Age is not a number")
      expect(errors_hash[1]["code"]).to eq("first_name_invalid")
      expect(errors_hash[1]["message"]).to eq("First name can't be blank")
      expect(errors_hash[2]["code"]).to eq("last_name_invalid")
      expect(errors_hash[2]["message"]).to eq("Last name starts with z.")
    end

    it "digs one level deep into the object for associated active-records" do
      holder = FakePersonHolder.new
      holder.name = nil
      holder.person = object

      holder.valid?

      errors = Stitches::Errors.from_active_record_object(holder)
      errors_hash = JSON.parse(errors.to_json).sort_by {|_| _["code"] }
      expect(errors_hash[0]["code"]).to eq("name_invalid")
      expect(errors_hash[0]["message"]).to eq("Name can't be blank")
      expect(errors_hash[1]["code"]).to eq("person_invalid")
      expect(errors_hash[1]["message"]).to eq("Age is not a number, First name can't be blank, Last name starts with z.")
    end

    it "works with nested attributes" do
      object.errors.add("something.nested", "is required")
      errors = Stitches::Errors.from_active_record_object(object)
      errors_hash = JSON.parse(errors.to_json).sort_by {|_| _["code"] }
      expect(errors_hash[0]["code"]).to eq("something-nested_invalid")
      expect(errors_hash[0]["message"]).to eq("Something nested is required")
    end
  end
end
