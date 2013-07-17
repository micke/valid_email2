require "valid_email2/version"
require "active_model"
require "active_model/validations"
require "resolv"
require "mail"

class EmailValidator < ActiveModel::EachValidator
  def self.disposable_emails
    @@disposable_emails ||= YAML.load_file(File.expand_path("../../disposable_emails.yml",__FILE__))
  end

  def default_options
    { regex: true, disposable: false, mx: false }
  end

  def validate_each(record, attribute, value)
    return unless value.present?
    options = default_options.merge(self.options)

    begin
      email = Mail::Address.new(value)
    rescue Mail::Field::ParseError
      error(record, attribute) && return
    end

    if email.domain && email.address == value
      tree = email.send(:tree)

      # Valid email needs to have a dot in the domain
      unless tree.domain.dot_atom_text.elements.size > 1
        error(record, attribute) && return
      end
    else
      error(record, attribute) && return
    end

    if options[:disposable]
      if self.class.disposable_emails.include?(email.domain)
        error(record, attribute) && return
      end
    end

    if options[:mx]
      mx = []

      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(email.domain, Resolv::DNS::Resource::IN::MX)
      end

      unless mx.any?
        error(record, attribute) && return
      end
    end
  end

  def error(record, attribute)
    record.errors.add(attribute, options[:message] || :invalid)
  end
end
