# frozen_string_literal: true

require "valid_email2/email_validator"

module ValidEmail2
  BLACKLIST_FILE  = "config/blacklisted_email_domains.yml"
  WHITELIST_FILE  = "config/whitelisted_email_domains.yml"
  DISPOSABLE_FILE = File.expand_path('../config/disposable_email_domains.txt', __dir__)

  def self.disposable_emails
    @disposable_emails ||= load_file(DISPOSABLE_FILE)
  end

  def self.blacklist
    @blacklist ||= load_if_exists(BLACKLIST_FILE)
  end

  def self.whitelist
    @whitelist ||= load_if_exists(WHITELIST_FILE)
  end

private

  def self.load_if_exists(path)
    File.exist?(path) ? load_file(path) : Set.new
  end

  def self.load_file(path)
    # This method MUST return a Set, otherwise the
    # performance will suffer!
    if path.end_with?(".yml")
      Set.new(YAML.load_file(path))
    else
      result = Set.new
      File.open(path, "r").each_line do |line|
        line.strip!
        result << line if line.present?
      end
      result
    end
  end
end
