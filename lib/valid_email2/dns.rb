require "resolv"
require "logger" # Fix concurrent-ruby removing logger dependency which Rails itself does not have
require "active_support"
require "active_support/cache"

module ValidEmail2
  class Dns
    DEFAULT_CACHE_SIZE_BYTES = 1024 * 1024

    class << self
      attr_reader :cache, :cache_size

      def cache_size=(bytes)
        @cache_size = bytes
        # Cached records are never mutated, so they don't need MemoryStore's defensive copies.
        @cache = ActiveSupport::Cache::MemoryStore.new(size: bytes, coder: nil)
      end

      def clear_cache
        cache.clear
      end
    end

    self.cache_size = DEFAULT_CACHE_SIZE_BYTES

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

      records = Resolv::DNS.open(resolv_config) do |dns|
        dns.timeouts = @dns_timeout
        dns.getresources(domain, type)
      end

      if records.any?
        ttl = records.map(&:ttl).min
        cache_records(cache_key, records, ttl)
      end

      records
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
      config
    end
  end
end
