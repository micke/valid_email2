# frozen_string_literal: true

require "valid_email2/email_validator"
require "valid_email2/sorted_domain_list"

module ValidEmail2
  DENY_LIST_FILE  = "config/deny_listed_email_domains.yml"
  ALLOW_LIST_FILE  = "config/allow_listed_email_domains.yml"
  DISPOSABLE_FILE = File.expand_path('../config/disposable_email_domains.txt', __dir__)
  DISPOSABLE_DOMAINS_LOOKUPS = %i[set sorted_list].freeze

  class << self
    # How disposable domains are looked up:
    # - :set (default): the Set of disposable_emails, about 35 MB, with the fastest lookups;
    # - :sorted_list: a SortedDomainList, about 3 MB, with lookups of a few microseconds.
    def disposable_domains_lookup
      @disposable_domains_lookup || :set
    end

    def disposable_domains_lookup=(lookup)
      unless DISPOSABLE_DOMAINS_LOOKUPS.include?(lookup)
        raise ArgumentError, "disposable_domains_lookup must be one of #{DISPOSABLE_DOMAINS_LOOKUPS.inspect}, " \
                             "got #{lookup.inspect}"
      end

      @disposable_domains_lookup = lookup
    end

    def disposable_emails
      @disposable_emails ||= load_file(DISPOSABLE_FILE)
    end

    # The disposable domains lookups use, as chosen by disposable_domains_lookup.
    def disposable_domains
      if disposable_domains_lookup == :sorted_list
        @sorted_disposable_domains ||= SortedDomainList.new(DISPOSABLE_FILE)
      else
        disposable_emails
      end
    end

    def deny_list
      @deny_list ||= load_if_exists(DENY_LIST_FILE) || Set.new
    end

    def allow_list
      @allow_list ||= load_if_exists(ALLOW_LIST_FILE) || Set.new
    end

    private

    def load_if_exists(path)
      load_file(path) if File.exist?(path)
    end

    def load_file(path)
      # This method MUST return a Set, otherwise the
      # performance will suffer!
      if path.end_with?(".yml")
        Set.new(YAML.load_file(path))
      else
        File.open(path, "r").each_line.each_with_object(Set.new) do |domain, set|
          set << domain.tap(&:chomp!)
        end
      end
    end
  end
end
