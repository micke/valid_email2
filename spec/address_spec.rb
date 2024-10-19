# frozen_string_literal: true

require "spec_helper"

describe ValidEmail2::Address do
  describe "#valid?" do
    it "is valid" do
      address = described_class.new("foo@bar123.com")
      expect(address.__send__(:address_contain_emoticons?)).to eq false
      expect(address.valid?).to be true
    end

    it "is invalid if email is nil" do
      address = described_class.new(nil)
      expect(address.valid?).to be false
    end

    it "is invalid if email is empty" do
      address = described_class.new(" ")
      expect(address.valid?).to be false
    end

    it "is invalid if domain is missing" do
      address = described_class.new("foo")
      expect(address.valid?).to be false
    end

    it "is invalid if email cannot be parsed" do
      address = described_class.new("<>")
      expect(address.valid?).to be false
    end

    it "is invalid if email contains emoticons" do
      address = described_class.new("foo🙈@gmail.com")
      expect(address.valid?).to be false
    end

    it "is valid if it contains special scandinavian characters" do
      address = described_class.new("jørgen@email.dk")
      expect(address.__send__(:address_contain_emoticons?)).to eq false
      expect(address.valid?).to eq true
    end
  end
end
