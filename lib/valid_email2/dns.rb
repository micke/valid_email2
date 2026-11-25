require "resolv"
require "logger" # Fix concurrent-ruby removing logger dependency which Rails itself does not have
require "active_support"
require "active_support/cache"

module ValidEmail2
  class Dns
    DEFAULT_CACHE_SIZE_BYTES = 1024 * 1024

    # Class variables, so that subclasses share the one cache; a class's instance variables aren't inherited.
    # rubocop:disable Style/ClassVars
    class << self
      def cache
        @@cache
      end

      def cache_size
        @@cache_size
      end

      def cache_size=(bytes)
        @@cache_size = bytes
        # Cached records are never mutated, so they don't need MemoryStore's defensive copies.
        @@cache = ActiveSupport::Cache::MemoryStore.new(size: bytes, coder: nil)
      end

      def clear_cache
        cache.clear
      end

      def raise_on_failure
        @@raise_on_failure
      end

      # Resolv raises a timeout only from 0.3.0 (bundled with Ruby 3.3); an older one would answer it as "no records".
      def raise_on_failure=(value)
        raise ArgumentError, "raise_on_failure needs the resolv gem 0.3.0 or later (Ruby 3.3)" if value && !resolv_raises_timeouts?

        @@raise_on_failure = value
      end

      private

      def resolv_raises_timeouts?
        Resolv.const_defined?(:VERSION) && Gem::Version.new(Resolv::VERSION) >= Gem::Version.new("0.3.0")
      end
    end
    # rubocop:enable Style/ClassVars

    # Resolv answers a SERVFAIL or REFUSED with no records, the same as NXDOMAIN, and has no option to raise instead:
    # Config#resolv rescues the error the query raised. This notes the error before that and raises it after.
    class FailureRaisingResolver < Resolv::DNS
      module RaisingConfig
        def resolv(name)
          failure = nil
          super(name) do |*query|
            yield(*query)
          rescue Resolv::DNS::Config::OtherResolvError => e
            failure = e
            raise
          end
          raise failure if failure
        end
      end

      def initialize(config_info = nil)
        super
        @config.extend RaisingConfig
      end
    end
    private_constant :FailureRaisingResolver

    self.cache_size = DEFAULT_CACHE_SIZE_BYTES
    self.raise_on_failure = false

    def initialize(dns_timeout = 5, dns_nameserver = nil)
      @dns_timeout = dns_timeout
      @dns_nameserver = dns_nameserver
    end

    def mx_servers(domain)
      fetch(domain, Resolv::DNS::Resource::IN::MX)
    end

    def a_servers(domain)
      fetch(domain, Resolv::DNS::Resource::IN::A)
    end

    private

    def fetch(domain, type)
      cache_key = "#{domain.downcase}/#{type}"
      cached_records = self.class.cache.read(cache_key)
      return cached_records if cached_records

      records = lookup(Resolv::DNS, domain, type)
      # Only an empty answer can hide a failure, so only that one is asked again.
      records = lookup(FailureRaisingResolver, domain, type) if records.empty? && self.class.raise_on_failure

      if records.any?
        ttl = records.map(&:ttl).min
        cache_records(cache_key, records, ttl)
      end

      records
    end

    def lookup(resolver, domain, type)
      resolver.open(resolv_config) do |dns|
        dns.timeouts = @dns_timeout
        dns.getresources(domain, type)
      end
    end

    def cache_records(cache_key, records, ttl)
      self.class.cache.write(cache_key, records, expires_in: ttl)
    rescue TypeError
      # MemoryStore sizes entries with Marshal, which can't dump test doubles
    end

    def resolv_config
      config = Resolv::DNS::Config.default_config_hash
      # REM: resolv gem 0.6.1 on linux can return frozen hash
      config = config.merge(nameserver: @dns_nameserver) if @dns_nameserver
      config = config.merge(raise_timeout_errors: true) if self.class.raise_on_failure
      config
    end
  end
end
