# frozen_string_literal: true

require "valid_email2/email_validator"
require_relative "./helpers/deprecation_helper"

module ValidEmail2
  
  BLACKLIST_FILE  = "config/blacklisted_email_domains.yml"
  DENY_LIST_FILE  = "config/deny_listed_email_domains.yml"
  WHITELIST_FILE  = "config/whitelisted_email_domains.yml"
  ALLOW_LIST_FILE  = "config/allow_listed_email_domains.yml"
  DISPOSABLE_FILE = File.expand_path('../config/disposable_email_domains.txt', __dir__)

  class << self
    extend DeprecationHelper

    def disposable_emails
      @disposable_emails ||= load_file(DISPOSABLE_FILE)
    end

    def blacklist
      @deny_list ||= load_if_exists(DENY_LIST_FILE || BLACKLIST_FILE)
    end
    alias_method :deny_list, :blacklist
    deprecate_method :blacklist, :deny_list

    def whitelist
      @allow_list ||= load_if_exists(ALLOW_LIST_FILE || WHITELIST_FILE)
    end
    alias_method :allow_list, :whitelist
    deprecate_method :whitelist, :allow_list

    private

    def load_if_exists(path)
      File.exist?(path) ? load_file(path) : Set.new
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
