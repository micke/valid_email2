# frozen_string_literal: true

require "spec_helper"

describe ValidEmail2::Dns do
  describe "#mx_servers" do
    it "gets a record" do
      dns = described_class.new
      records = dns.mx_servers("gmail.com")
      expect(records.size).to_not be_zero
    end
  end

  describe "#a_servers" do
    it "gets a record" do
      dns = described_class.new
      records = dns.a_servers("gmail.com")
      expect(records.size).to_not be_zero
    end
  end
end
