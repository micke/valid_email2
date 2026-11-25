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

    it "shares the cache with subclasses" do
      subclass = Class.new(described_class)

      described_class.new.mx_servers("example.com")
      subclass.new.mx_servers("example.com")
      subclass.clear_cache
      described_class.new.mx_servers("example.com")

      expect(Resolv::DNS).to have_received(:open).twice
    end
  end

  describe "raise_on_failure" do
    # Answers every query with the given response code, or never answers when it is nil.
    def start_dns_server(rcode)
      socket = UDPSocket.new
      socket.bind("127.0.0.1", 0)
      thread = Thread.new do
        loop do
          data, (_, port, host) = socket.recvfrom(512)
          next unless rcode

          query = Resolv::DNS::Message.decode(data)
          reply = Resolv::DNS::Message.new(query.id)
          reply.qr = 1
          reply.rcode = rcode
          query.each_question { |name, typeclass| reply.add_question(name, typeclass) }
          socket.send(reply.encode, 0, host, port)
        end
      end
      @servers << [socket, thread]
      socket.addr[1]
    end

    def mx_servers_from(rcode)
      port = start_dns_server(rcode)
      allow(Resolv::DNS::Config).to receive(:default_config_hash)
        .and_return(nameserver_port: [["127.0.0.1", port]], search: [], ndots: 1)
      described_class.new(0.2).mx_servers("example.com")
    end

    before { @servers = [] }

    after do
      @servers.each do |socket, thread|
        thread.kill
        socket.close
      end
      described_class.raise_on_failure = false
      described_class.clear_cache
    end

    it "is off by default, so a failure answers no records" do
      expect(described_class.raise_on_failure).to be(false)
      expect(mx_servers_from(Resolv::DNS::RCode::ServFail)).to eq([])
    end

    context "when on" do
      before do
        skip "needs the resolv gem 0.3.0 or later" unless Resolv.const_defined?(:VERSION)
        described_class.raise_on_failure = true
      end

      it "raises on a SERVFAIL" do
        expect { mx_servers_from(Resolv::DNS::RCode::ServFail) }.to raise_error(Resolv::ResolvError)
      end

      it "raises on a REFUSED" do
        expect { mx_servers_from(Resolv::DNS::RCode::Refused) }.to raise_error(Resolv::ResolvError)
      end

      it "raises on a timeout" do
        expect { mx_servers_from(nil) }.to raise_error(Resolv::ResolvError, /timeout/)
      end

      it "answers no records for a domain that does not exist" do
        expect(mx_servers_from(Resolv::DNS::RCode::NXDomain)).to eq([])
      end

      it "is shared with subclasses" do
        expect(Class.new(described_class).raise_on_failure).to be(true)
      end
    end

    it "is rejected on a resolv that cannot raise a timeout" do
      hide_const("Resolv::VERSION")

      expect { described_class.raise_on_failure = true }.to raise_error(ArgumentError, /resolv gem 0.3.0/)
    end
  end
end
