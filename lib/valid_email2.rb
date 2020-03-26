# frozen_string_literal: true

require "valid_email2/email_validator"

module ValidEmail2
  BLACKLIST_FILE  = "config/blacklisted_email_domains.yml"
  WHITELIST_FILE  = "config/whitelisted_email_domains.yml"
  DISPOSABLE_FILE = File.expand_path('../config/disposable_email_domains.txt', __dir__)

  def self.disposable_emails
    @disposable_emails ||= File.open(DISPOSABLE_FILE){ |f| f.read }.split("\n")
  end

  def self.blacklist
    @blacklist ||= if File.exist?(BLACKLIST_FILE)
                     YAML.load_file(File.expand_path(BLACKLIST_FILE))
                   else
                     []
                   end
  end

  def self.whitelist
    @whitelist ||= if File.exist?(WHITELIST_FILE)
                     YAML.load_file(File.expand_path(WHITELIST_FILE))
                   else
                     []
                   end
  end
end
