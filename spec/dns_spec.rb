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

  describe "cache" do
    let(:resolv_dns) { instance_double(Resolv::DNS, :timeouts= => nil) }
    let(:mx_record) do
      record = Resolv::DNS::Resource::IN::MX.new(10, Resolv::DNS::Name.create("mx.example.com"))
      record.instance_variable_set(:@ttl, 1_000)
      record
    end

    before do
      allow(Resolv::DNS).to receive(:open).and_yield(resolv_dns)
      allow(resolv_dns).to receive(:getresources).and_return([mx_record])
    end

    after do
      described_class.cache_size = described_class::DEFAULT_CACHE_SIZE_BYTES
    end

    it "keeps lookups that fit into the cache" do
      described_class.cache_size = 1024

      2.times { described_class.new.mx_servers("example.com") }

      expect(Resolv::DNS).to have_received(:open).once
    end

    it "evicts lookups once the cache grows past the configured size" do
      described_class.cache_size = 1

      2.times { described_class.new.mx_servers("example.com") }

      expect(Resolv::DNS).to have_received(:open).twice
    end

    it "looks up records that can't be cached, such as test doubles, every time" do
      mx_double = double("MX", exchange: "mx.example.com", preference: 10, ttl: 1_000)
      allow(resolv_dns).to receive(:getresources).and_return([mx_double])

      results = Array.new(2) { described_class.new.mx_servers("example.com") }

      expect(results).to eq([[mx_double], [mx_double]])
      expect(Resolv::DNS).to have_received(:open).twice
    end
  end
end
