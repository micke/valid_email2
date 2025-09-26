require "resolv"

module ValidEmail2
  class Dns
    MAX_CACHE_SIZE = 1_000
    CACHE = {}

    CacheEntry = Struct.new(:records, :cached_at, :ttl)

    def self.prune_cache
      entries_sorted_by_cached_at_asc = CACHE.sort_by { |key, data| data.cached_at }
      entries_to_remove = entries_sorted_by_cached_at_asc.first(CACHE.size - MAX_CACHE_SIZE)
      entries_to_remove.each { |key, _value| CACHE.delete(key) }
    end

    def self.clear_cache
      CACHE.clear
    end

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

    def prune_cache
      self.class.prune_cache
    end

    def fetch(domain, type)
      prune_cache if CACHE.size > MAX_CACHE_SIZE

      domain = domain.downcase
      cache_key = [domain, type]
      cache_entry = CACHE[cache_key]

      if cache_entry && Time.now - cache_entry.cached_at < cache_entry.ttl
        return cache_entry.records
      else
        CACHE.delete(cache_key)
      end

      records = Resolv::DNS.open(resolv_config) do |dns|
        dns.timeouts = @dns_timeout
        dns.getresources(domain, type)
      end

      if records.any?
        ttl = records.map(&:ttl).min
        CACHE[cache_key] = CacheEntry.new(records, Time.now, ttl)
      end

      records
    end

    def resolv_config
      config = Resolv::DNS::Config.default_config_hash
      # REM: resolv gem 0.6.1 on linux can return frozen hash
      config = config.merge(nameserver: @dns_nameserver) if @dns_nameserver
      config
    end
  end
end
