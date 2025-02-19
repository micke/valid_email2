# frozen_string_literal: true

require "spec_helper"

describe ValidEmail2::Address do
  before do
    ValidEmail2::Dns.clear_cache
  end

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
        expect(address.valid?).to be_truthy
      end
    end
  end

  describe "#disposable_domain?" do
    context "when the disposable domain does not have subdomains" do
      let(:disposable_domain) { ValidEmail2.disposable_emails.select { |domain| domain.count(".") == 1 }.sample }

      it "is true if the domain is in the disposable_emails list" do
        address = described_class.new("foo@#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end

      it "is true if the domain is a subdomain of a disposable domain" do
        address = described_class.new("foo@sub.#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end

      it "is true if the domain is a deeply nested subdomain of a disposable domain" do
        address = described_class.new("foo@sub3.sub2.sub1.#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end

      it "is false if the domain is not in the disposable_emails list" do
        address = described_class.new("foo@example.com")
        expect(address.disposable_domain?).to eq false
      end
    end

    context "when the disposable domain has subdomains" do
      let(:disposable_domain) { ValidEmail2.disposable_emails.select { |domain| domain.count(".") > 1 }.sample }

      it "is true if the domain is in the disposable_emails list" do
        address = described_class.new("foo@#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end

      it "is true if the domain is a subdomain of a disposable domain" do
        address = described_class.new("foo@sub.#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end

      it "is true if the domain is a deeply nested subdomain of a disposable domain" do
        address = described_class.new("foo@sub3.sub2.sub1.#{disposable_domain}")
        expect(address.disposable_domain?).to be_truthy
      end
    end
  end

  describe "caching" do
    let(:email_address) { "example@ymail.com" }
    let(:dns_instance) { ValidEmail2::Dns.new }
    let(:email_instance) { described_class.new(email_address, dns_instance) }
    let(:ttl) { 1_000 }
    let(:mock_resolv_dns) { instance_double(Resolv::DNS) }
    let(:mock_mx_records) { [double("MX", exchange: "mx.ymail.com", preference: 10, ttl:)] }

    before do
      allow(email_instance).to receive(:null_mx?).and_return(false)
      allow(Resolv::DNS).to receive(:open).and_yield(mock_resolv_dns)
      allow(mock_resolv_dns).to receive(:timeouts=)
    end

    describe "#disposable_mx_server?" do
      let(:disposable_email_address) { "example@10minutemail.com" }
      let(:disposable_mx_server) { ValidEmail2.disposable_emails.select { |domain| domain.count(".") == 1 }.sample }
      let(:disposable_email_instance) { described_class.new(disposable_email_address, dns_instance) }
      let(:mock_disposable_mx_records) { [double("MX", exchange: "mx.#{disposable_mx_server}", preference: 10, ttl:)] }

      before do
        allow(mock_resolv_dns).to receive(:getresources)
          .with(disposable_email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return(mock_disposable_mx_records)

        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return(mock_mx_records)
      end

      it "is false if the MX server is not in the disposable_emails list" do
        expect(email_instance).not_to be_disposable_mx_server
      end

      it "is true if the MX server is in the disposable_emails list" do
        expect(disposable_email_instance).to be_disposable_mx_server
      end

      it "is false and then true when the MX record changes from non-disposable to disposable" do
        allow(mock_resolv_dns).to receive(:getresources)
          .with(disposable_email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return(mock_mx_records) # non-disposable MX records

        expect(disposable_email_instance).not_to be_disposable_mx_server

        ValidEmail2::Dns.clear_cache

        allow(mock_resolv_dns).to receive(:getresources)
          .with(disposable_email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
          .and_return(mock_disposable_mx_records) # disposable MX records

        expect(disposable_email_instance).to be_disposable_mx_server
      end
    end

    describe "#valid_strict_mx?" do
      let(:cached_at) { Time.now }
      let(:mock_cache_data) { { [email_instance.address.domain, Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_mx_records, cached_at, ttl) } }

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
          stub_const("ValidEmail2::Dns::CACHE", mock_cache_data)
          allow(ValidEmail2::Dns).to receive(:new).and_return(dns_instance)
          allow(dns_instance).to receive(:fetch).with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX).and_call_original
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
          stub_const("ValidEmail2::Dns::CACHE", mock_cache_data)
          allow(ValidEmail2::Dns).to receive(:new).and_return(dns_instance)
          allow(dns_instance).to receive(:fetch).with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX).and_call_original
        end

        context "when the cache size is less than or equal to the max cache size" do
          before do
            stub_const("ValidEmail2::Dns::MAX_CACHE_SIZE", 1)
          end

          it "does not prune the cache" do
            expect(dns_instance).not_to receive(:prune_cache)

            email_instance.valid_strict_mx?
          end

          it "does not call the MX servers lookup" do
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).not_to have_received(:open)
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { ["another_domain.com", Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_mx_records, cached_at - 100, ttl) } }

            it "does not prune those entries" do
              email_instance.valid_strict_mx?

              expect(ValidEmail2::Dns::CACHE.keys).to match_array([[email_instance.address.domain, Resolv::DNS::Resource::IN::MX], ["another_domain.com", Resolv::DNS::Resource::IN::MX]])
            end
          end
        end

        context "when the cache size is greater than the max cache size" do
          before do
            stub_const("ValidEmail2::Dns::MAX_CACHE_SIZE", 0)
          end

          it "prunes the cache" do
            expect(dns_instance).to receive(:prune_cache).once

            email_instance.valid_strict_mx?
          end

          it "calls the the MX servers lookup" do
            email_instance.valid_strict_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { ["another_domain.com", Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_mx_records, cached_at - 100, ttl) } }

            it "prunes those entries" do
              email_instance.valid_strict_mx?

              expect(ValidEmail2::Dns::CACHE.keys).to match_array([[email_instance.address.domain, Resolv::DNS::Resource::IN::MX]])
            end
          end
        end
      end
    end

    describe "#valid_mx?" do
      let(:cached_at) { Time.now }
      let(:mock_cache_data) { { [email_instance.address.domain, Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_a_records, cached_at, ttl) } }
      let(:mock_a_records) { [double("A", address: "192.168.1.1", ttl:)] }

      before do
        allow(email_instance).to receive(:mx_servers).and_return(mock_mx_records)
        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX)
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
          stub_const("ValidEmail2::Dns::CACHE", mock_cache_data)
          allow(ValidEmail2::Dns).to receive(:new).and_return(dns_instance)
          allow(dns_instance).to receive(:fetch).with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX).and_call_original
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
          stub_const("ValidEmail2::Dns::CACHE", mock_cache_data)
          allow(ValidEmail2::Dns).to receive(:new).and_return(dns_instance)
          allow(dns_instance).to receive(:fetch).with(email_instance.address.domain, Resolv::DNS::Resource::IN::MX).and_call_original
        end

        context "when the cache size is less than or equal to the max cache size" do
          before do
            stub_const("ValidEmail2::Dns::MAX_CACHE_SIZE", 1)
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
            let(:mock_cache_data) { { ["another_domain.com", Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_a_records, cached_at - 100, ttl) } }

            it "does not prune those entries" do
              email_instance.valid_mx?

              expect(ValidEmail2::Dns::CACHE.keys).to match_array([[email_instance.address.domain, Resolv::DNS::Resource::IN::MX], ["another_domain.com", Resolv::DNS::Resource::IN::MX]])
            end
          end
        end

        context "when the cache size is greater than the max cache size" do
          before do
            stub_const("ValidEmail2::Dns::MAX_CACHE_SIZE", 0)
          end

          it "prunes the cache" do
            expect(dns_instance).to receive(:prune_cache).once

            email_instance.valid_mx?
          end

          it "calls the MX or A servers lookup" do
            email_instance.valid_mx?

            expect(Resolv::DNS).to have_received(:open).once
          end

          context "and there are older cached entries" do
            let(:mock_cache_data) { { ["another_domain.com", Resolv::DNS::Resource::IN::MX] => ValidEmail2::Dns::CacheEntry.new(mock_a_records, cached_at - 100, ttl) } }

            it "prunes those entries" do
              email_instance.valid_mx?

              expect(ValidEmail2::Dns::CACHE.keys).to match_array([[email_instance.address.domain, Resolv::DNS::Resource::IN::MX]])
            end
          end
        end
      end
    end
  end
end
