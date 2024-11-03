module ValidEmail2
  class DnsRecordsCache
    MAX_CACHE_SIZE = 1_000

    def initialize
      # Cache structure: { domain (String): { records: [], cached_at: Time, ttl: Integer } }
      @cache = {}
    end

    def fetch(domain, &block)
      prune_cache if @cache.size > MAX_CACHE_SIZE

      cache_entry = @cache[domain]

      if cache_entry && (Time.now - cache_entry[:cached_at]) < cache_entry[:ttl]
        return cache_entry[:records]
      else
        @cache.delete(domain)
      end

      records = block.call

      if records.any?
        ttl = records.map(&:ttl).min
        @cache[domain] = { records: records, cached_at: Time.now, ttl: ttl }
      end

      records
    end

    def prune_cache
      entries_sorted_by_cached_at_asc = (@cache.sort_by { |_domain, data| data[:cached_at] }).flatten
      entries_to_remove = entries_sorted_by_cached_at_asc.first(@cache.size - MAX_CACHE_SIZE)
      entries_to_remove.each { |domain| @cache.delete(domain) }
    end
  end
end