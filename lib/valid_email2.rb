# frozen_string_literal: true

require "valid_email2/email_validator"

module ValidEmail2
  DENY_LIST_FILE  = "config/deny_listed_email_domains.yml"
  ALLOW_LIST_FILE  = "config/allow_listed_email_domains.yml"
  DISPOSABLE_FILE = File.expand_path('../config/disposable_email_domains.txt', __dir__)

  class << self
    def disposable_emails
      @disposable_emails ||= load_file(DISPOSABLE_FILE)
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
