require "resolv"

module ValidEmail2
  class Dns
    MAX_CACHE_SIZE = 1_000
    CACHE = {}
    MX_SERVERS_CACHE = {}
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

    def mx_servers_disposable?(domain, domain_list)
      servers = mx_servers(domain)
      cache_key = generate_mx_cache_key(domain, domain_list, servers)
      return MX_SERVERS_CACHE[cache_key] if !cache_key.nil? && MX_SERVERS_CACHE.key?(cache_key)

      result = servers.any? do |mx_server|
        return false unless mx_server.respond_to?(:exchange)

        mx_server = mx_server.exchange.to_s

        domain_list.any? do |disposable_domain|
          mx_server.end_with?(disposable_domain) && mx_server.match?(/\A(?:.+\.)*?#{disposable_domain}\z/)
        end
      end

      MX_SERVERS_CACHE[cache_key] = result unless cache_key.nil?

      result
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
      config[:nameserver] = @dns_nameserver if @dns_nameserver
      config
    end

    def generate_mx_cache_key(domain, domain_list, mx_servers)
      return if mx_servers.empty? || domain_list.empty?

      mx_servers_str = mx_servers.map(&:exchange).map(&:to_s).sort.join
      return domain if mx_servers_str.empty?

      "#{domain_list.object_id}_#{domain_list.length}_#{mx_servers_str.downcase}"
    end
  end
end
