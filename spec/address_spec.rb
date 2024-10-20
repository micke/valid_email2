# frozen_string_literal: true

require "spec_helper"

describe ValidEmail2::Address do
  describe "#valid?" do
    it "is valid" do
      address = described_class.new("foo@bar123.com")
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
  end

  describe "caching" do
    let(:email_address) { "example@ymail.com" }
    let(:email_instance) { described_class.new(email_address) }
    let(:mock_resolv_dns) { instance_double(Resolv::DNS) }
    let(:mock_mx_records) { [double('MX', exchange: 'mx.ymail.com', preference: 10)] }

    before do
      allow(email_instance).to receive(:null_mx?).and_return(false)
      allow(Resolv::DNS).to receive(:open).and_yield(mock_resolv_dns)
      allow(mock_resolv_dns).to receive(:timeouts=)
    end

    describe "#valid_strict_mx?" do
      before do
        described_class.class_variable_set(:@@mx_servers_cache, {})
        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return(mock_mx_records)
      end

      it "calls the MX servers lookup when the email is not cached" do
        result = email_instance.valid_strict_mx?

        expect(Resolv::DNS).to have_received(:open).once
        expect(result).to be true
      end

      it "does not call the MX servers lookup when the email is cached" do
        email_instance.valid_strict_mx?
        email_instance.valid_strict_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "returns the cached result for subsequent calls" do
        first_result = email_instance.valid_strict_mx?
        expect(first_result).to be true

        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return([])

        second_result = email_instance.valid_strict_mx?
        expect(second_result).to be true
      end
    end

    describe "#valid_mx?" do
      let(:mock_a_records) { [double('A', address: '192.168.1.1')] }

      before do
        described_class.class_variable_set(:@@mx_or_a_servers_cache, {})
        allow(email_instance).to receive(:mx_servers).and_return(mock_mx_records)
        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::A)
          .and_return(mock_a_records)
      end

      it "calls the MX or A servers lookup when the email is not cached" do
        result = email_instance.valid_mx?

        expect(Resolv::DNS).to have_received(:open).once
        expect(result).to be true
      end

      it "does not call the MX or A servers lookup when the email is cached" do
        email_instance.valid_mx?
        email_instance.valid_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "returns the cached result for subsequent calls" do
        first_result = email_instance.valid_mx?
        expect(first_result).to be true

        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::A)
          .and_return([])

        second_result = email_instance.valid_mx?
        expect(second_result).to be true
      end
    end
  end
end
