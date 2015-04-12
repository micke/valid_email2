require 'valid_email2/email_validator'

module ValidEmail2
  def self.load_deleted=(value)
    @@load_deleted = value
    @@disposable_emails = nil
  end

  def self.disposable_emails
    @@disposable_emails ||= load_disposable_emails
  end

  def self.blacklist
    blacklist_file = 'vendor/blacklist.yml'
    @@blacklist ||= File.exists?(blacklist_file) ? YAML.load_file(File.expand_path(blacklist_file)) : []
  end

  protected

  def self.load_disposable_emails
    dir = File.expand_path('../../vendor', __FILE__)
    standard = YAML.load_file(File.join(dir, 'disposable_emails.yml'))
    deleted = @@load_deleted ? YAML.load_file(File.join(dir, 'disposable_emails_deleted.yml')) : []
    standard + deleted
  end
end
