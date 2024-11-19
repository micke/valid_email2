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

    it "is invalid if it contains Japanese characters" do
      address = described_class.new("あいうえお@example.com")
      expect(address.valid?).to be false
    end

    it "is invalid if it contains special scandinavian characters" do
      address = described_class.new("jørgen@email.dk")
      expect(address.valid?).to eq false
    end

    context "permitted_multibyte_characters_regex is set" do
      before do
        described_class.permitted_multibyte_characters_regex = /[ÆæØøÅåÄäÖöÞþÐð]/
      end

      it "is valid if it contains special scandinavian characters" do
        address = described_class.new("jørgen@email.dk")
        expect(address.valid?).to eq true
      end
    end
  end

  describe "caching" do
    let(:email_address) { "example@ymail.com" }
    let(:email_instance) { described_class.new(email_address) }
    let(:dns_records_cache_instance) { ValidEmail2::DnsRecordsCache.new }
    let(:ttl) { 1_000 }
    let(:mock_resolv_dns) { instance_double(Resolv::DNS) }
    let(:mock_mx_records) { [double("MX", exchange: "mx.ymail.com", preference: 10, ttl: ttl)] }

    before do
      allow(email_instance).to receive(:null_mx?).and_return(false)
      allow(Resolv::DNS).to receive(:open).and_yield(mock_resolv_dns)
      allow(mock_resolv_dns).to receive(:timeouts=)
    end

    describe "#valid_strict_mx?" do
      let(:cached_at) { Time.now }
      let(:mock_cache_data) { { email_instance.address.domain => { records: mock_mx_records, cached_at: cached_at, ttl: ttl } } }

      before do
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

      describe "ttl" do
        before do
          dns_records_cache_instance.instance_variable_set(:@cache, mock_cache_data)
          allow(ValidEmail2::DnsRecordsCache).to receive(:new).and_return(dns_records_cache_instance)
          allow(dns_records_cache_instance).to receive(:fetch).with(email_instance.address.domain).and_call_original
        end

        context "when the time since last lookup is less than the cached ttl entry" do
          let(:cached_at) { Time.now }

          it "does not call the MX servers lookup" do
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).not_to have_received(:open)
          end
        end

        context "when the time since last lookup is greater than the cached ttl entry" do
          let(:cached_at) { Time.now - ttl }

          it "calls the MX servers lookup" do
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end
        end
      end

      describe "cache size" do
        before do
          dns_records_cache_instance.instance_variable_set(:@cache, mock_cache_data)
          allow(ValidEmail2::DnsRecordsCache).to receive(:new).and_return(dns_records_cache_instance)
          allow(dns_records_cache_instance).to receive(:fetch).with(email_instance.address.domain).and_call_original
        end

        context "when the cache size is less than or equal to the max cache size" do
          before do
            stub_const("ValidEmail2::DnsRecordsCache::MAX_CACHE_SIZE", 1)
          end

          it "does not prune the cache" do
            expect(dns_records_cache_instance).not_to receive(:prune_cache)

            email_instance.valid_strict_mx?
          end

          it "does not call the MX servers lookup" do
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).not_to have_received(:open)
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { "another_domain.com" => { records: mock_mx_records, cached_at: cached_at - 100, ttl: ttl } } }

            it "does not prune those entries" do
              email_instance.valid_strict_mx?

              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys.size).to eq 2
              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys).to match_array([email_instance.address.domain, "another_domain.com"])
            end
          end
        end

        context "when the cache size is greater than the max cache size" do
          before do
            stub_const("ValidEmail2::DnsRecordsCache::MAX_CACHE_SIZE", 0)
          end

          it "prunes the cache" do
            expect(dns_records_cache_instance).to receive(:prune_cache).once

            email_instance.valid_strict_mx?
          end

          it "calls the the MX servers lookup" do    
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { "another_domain.com" => { records: mock_mx_records, cached_at: cached_at - 100, ttl: ttl } } }

            it "prunes those entries" do
              email_instance.valid_strict_mx?

              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys.size).to eq 1
              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys).to match_array([email_instance.address.domain])
            end
          end
        end
      end
    end

    describe "#valid_mx?" do
      let(:cached_at) { Time.now }
      let(:mock_cache_data) { { email_instance.address.domain => { records: mock_a_records, cached_at: cached_at, ttl: ttl } } }
      let(:mock_a_records) { [double("A", address: "192.168.1.1", ttl: ttl)] }

      before do
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

      describe "ttl" do
        before do
          dns_records_cache_instance.instance_variable_set(:@cache, mock_cache_data)
          allow(ValidEmail2::DnsRecordsCache).to receive(:new).and_return(dns_records_cache_instance)
          allow(dns_records_cache_instance).to receive(:fetch).with(email_instance.address.domain).and_call_original
        end

        context "when the time since last lookup is less than the cached ttl entry" do
          let(:cached_at) { Time.now }

          it "does not call the MX or A servers lookup" do
            email_instance.valid_mx?

            expect(Resolv::DNS).not_to have_received(:open)
          end
        end

        context "when the time since last lookup is greater than the cached ttl entry" do
          let(:cached_at) { Time.now - ttl }

          it "calls the MX or A servers lookup " do
            email_instance.valid_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end
        end
      end

      describe "cache size" do
        before do
          dns_records_cache_instance.instance_variable_set(:@cache, mock_cache_data)
          allow(ValidEmail2::DnsRecordsCache).to receive(:new).and_return(dns_records_cache_instance)
          allow(dns_records_cache_instance).to receive(:fetch).with(email_instance.address.domain).and_call_original
        end

        context "when the cache size is less than or equal to the max cache size" do
          before do
            stub_const("ValidEmail2::DnsRecordsCache::MAX_CACHE_SIZE", 1)
          end

          it "does not prune the cache" do
            expect(email_instance).not_to receive(:prune_cache)

            email_instance.valid_mx?
          end

          it "does not call the MX or A servers lookup" do
            email_instance.valid_mx?

            expect(Resolv::DNS).not_to have_received(:open)
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { "another_domain.com" => { records: mock_a_records, cached_at: cached_at - 100, ttl: ttl } } }

            it "does not prune those entries" do
              email_instance.valid_mx?

              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys.size).to eq 2
              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys).to match_array([email_instance.address.domain, "another_domain.com"])
            end
          end
        end

        context "when the cache size is greater than the max cache size" do
          before do
            stub_const("ValidEmail2::DnsRecordsCache::MAX_CACHE_SIZE", 0)
          end

          it "prunes the cache" do 
            expect(dns_records_cache_instance).to receive(:prune_cache).once 

            email_instance.valid_mx?
          end

          it "calls the MX or A servers lookup" do
            email_instance.valid_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { "another_domain.com" => { records: mock_a_records, cached_at: cached_at - 100, ttl: ttl } } }

            it "prunes those entries" do
              email_instance.valid_mx?

              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys.size).to eq 1
              expect(dns_records_cache_instance.instance_variable_get(:@cache).keys).to match_array([email_instance.address.domain])
            end
          end
        end
      end    
    end
  end
end
