require "valid_email2/email_validator"

module ValidEmail2
  def self.disposable_emails
    @@disposable_emails ||= YAML.load_file(File.expand_path("../../vendor/disposable_emails.yml",__FILE__))
  end

  def self.blacklist
    blacklist_file = "vendor/blacklist.yml"
    @@blacklist ||= File.exists?(blacklist_file) ? YAML.load_file(File.expand_path(blacklist_file)) : []
  end

  def self.mx_whitelist
    mx_whitelist_file = "vendor/mx_whitelist.yml"
    @@mx_whitelist ||= File.exists?(mx_whitelist_file) ? YAML.load_file(File.expand_path(mx_whitelist_file)) : []
  end
end
