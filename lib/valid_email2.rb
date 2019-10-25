# frozen_string_literal: true

require "valid_email2/email_validator"

module ValidEmail2
  BLACKLIST_FILE = "config/blacklisted_email_domains.yml"
  WHITELIST_FILE = "config/whitelisted_email_domains.yml"

  def self.disposable_emails
    @disposable_emails ||= load_file(
      File.expand_path('../config/disposable_email_domains.yml', __dir__)
    )
  end

  def self.blacklist
    @blacklist ||= if File.exist?(BLACKLIST_FILE)
                     load_file(File.expand_path(BLACKLIST_FILE))
                   else
                     []
                   end
  end

  def self.whitelist
    @whitelist ||= if File.exist?(WHITELIST_FILE)
                     load_file(File.expand_path(WHITELIST_FILE))
                   else
                     []
                   end
  end

  def self.load_file(path)
    Set.new(YAML.load_file(path))
  end
end
