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

    it "is valid if it contains special scandinavian characters" do
      address = described_class.new("jørgen@email.dk")
      expect(address.valid?).to eq true
    end
  end

  describe "caching" do
    let(:email_address) { "example@ymail.com" }
    let(:email_instance) { described_class.new(email_address) }
    let(:ttl) { 1_000 }
    let(:mock_resolv_dns) { instance_double(Resolv::DNS) }
    let(:mock_mx_records) { [double('MX', exchange: 'mx.ymail.com', preference: 10, ttl: ttl)] }

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

      it "does not call the MX servers lookup when the cached time since last lookup is less than the cached ttl entry" do
        described_class.class_variable_set(:@@mx_servers_cache, { email_instance.address.domain => { records: mock_mx_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_strict_mx?

        expect(Resolv::DNS).not_to have_received(:open)
      end

      it "calls the MX servers lookup when the cached time since last lookup is greater than the cached ttl entry" do
        described_class.class_variable_set(:@@mx_servers_cache, { email_instance.address.domain => { records: mock_mx_records, cached_at: Time.now - ttl, ttl: ttl }}) # Cached 1 day ago
      
        email_instance.valid_strict_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "does not prune the cache when the cache size is less than the max cache size" do
        expect(email_instance).not_to receive(:prune_cache)

        email_instance.valid_strict_mx?
      end

      it "prunes the cache when the cache size is greater than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)

        expect(email_instance).to receive(:prune_cache).with(described_class.class_variable_get(:@@mx_servers_cache)).once

        email_instance.valid_strict_mx?
        email_instance.valid_strict_mx?
      end

      it "does not call the MX or A servers lookup when there is a cached entry for the domain and the cache size is less than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 1)
        described_class.class_variable_set(:@@mx_servers_cache, { email_instance.address.domain => { records: mock_mx_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_strict_mx?

        expect(Resolv::DNS).not_to have_received(:open)
      end

      it "calls the MX or A servers lookup when there is a cached entry for the domain but the cache size is greater than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)
        described_class.class_variable_set(:@@mx_servers_cache, { email_instance.address.domain => { records: mock_mx_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_strict_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "does not prune older entries when the cache size is less than the max size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 1)
        described_class.class_variable_set(:@@mx_servers_cache, {
          'another_domain.com' => {
            records: mock_mx_records, cached_at: Time.now - 100, ttl: ttl
          }
        })

        email_instance.valid_strict_mx?

        expect(described_class.class_variable_get(:@@mx_servers_cache).keys).to match_array([email_instance.address.domain, 'another_domain.com'])
      end

      it "prunes older entries when the cache size is greater than the max size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)
        described_class.class_variable_set(:@@mx_servers_cache, {
          'another_domain.com' => {
            records: mock_mx_records, cached_at: Time.now - 100, ttl: ttl
          }
        })

        email_instance.valid_strict_mx?

        expect(described_class.class_variable_get(:@@mx_servers_cache).keys).to match_array([email_instance.address.domain])
      end
    end

    describe "#valid_mx?" do
      let(:mock_a_records) { [double('A', address: '192.168.1.1', ttl: ttl)] }

      before do
        described_class.class_variable_set(:@@mx_or_a_servers_cache, {})
        allow(email_instance).to receive(:mx_servers).and_return(mock_mx_records)
        allow(mock_resolv_dns).to receive(:getresources)
          .with(email_instance.address.domain, Resolv::DNS::Resource::IN::A)
          .and_return(mock_a_records)
      end

      context "when the email is not cached" do
        it "calls the MX or A servers lookup" do
          result = email_instance.valid_mx?

          expect(Resolv::DNS).to have_received(:open).once
          expect(result).to be true
        end
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

      it "does not call the MX or A servers lookup when the time since last lookup is less than the cached ttl entry" do
        described_class.class_variable_set(:@@mx_or_a_servers_cache, { email_instance.address.domain => { records: mock_a_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_mx?

        expect(Resolv::DNS).not_to have_received(:open)
      end

      it "calls the MX or A servers lookup when the time since last lookup is greater than the cached ttl entry" do
        described_class.class_variable_set(:@@mx_or_a_servers_cache, { email_instance.address.domain => { records: mock_a_records, cached_at: Time.now - ttl, ttl: ttl }})

        email_instance.valid_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "does not prune the cache when the cache size is less than the max cache size" do
        expect(email_instance).not_to receive(:prune_cache)

        email_instance.valid_mx?
      end

      it "prunes the cache when the cache size is greater than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)

        expect(email_instance).to receive(:prune_cache).with(described_class.class_variable_get(:@@mx_or_a_servers_cache)).once

        email_instance.valid_mx?
        email_instance.valid_mx?
      end

      it "does not call the MX or A servers lookup when there is a cached entry for the domain and the cache size is less than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 1)
        described_class.class_variable_set(:@@mx_or_a_servers_cache, { email_instance.address.domain => { records: mock_a_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_mx?

        expect(Resolv::DNS).not_to have_received(:open)
      end

      it "calls the MX or A servers lookup when there is a cached entry for the domain but the cache size is greater than the max cache size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)
        described_class.class_variable_set(:@@mx_or_a_servers_cache, { email_instance.address.domain => { records: mock_a_records, cached_at: Time.now, ttl: ttl }})

        email_instance.valid_mx?

        expect(Resolv::DNS).to have_received(:open).once
      end

      it "does not prune older entries when the cache size is less than the max size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 1)
        described_class.class_variable_set(:@@mx_or_a_servers_cache, {
          'another_domain.com' => {
            records: mock_a_records, cached_at: Time.now - 100, ttl: ttl
          }
        })

        email_instance.valid_mx?

        expect(described_class.class_variable_get(:@@mx_or_a_servers_cache).keys).to match_array([email_instance.address.domain, 'another_domain.com'])
      end

      it "prunes older entries when the cache size is greater than the max size" do
        stub_const("#{described_class}::MAX_CACHE_SIZE", 0)
        described_class.class_variable_set(:@@mx_or_a_servers_cache, {
          'another_domain.com' => {
            records: mock_a_records, cached_at: Time.now - 100, ttl: ttl
          }
        })

        email_instance.valid_mx?

        expect(described_class.class_variable_get(:@@mx_or_a_servers_cache).keys).to match_array([email_instance.address.domain])
      end
    end
  end
end
