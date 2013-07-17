require "valid_email2/version"
require "valid_email2/address"
require "active_model"
require "active_model/validations"

module ValidEmail2
  def self.disposable_emails
    @@disposable_emails ||= YAML.load_file(File.expand_path("../../vendor/disposable_emails.yml",__FILE__))
  end
end

class EmailValidator < ActiveModel::EachValidator
  def default_options
    { regex: true, disposable: false, mx: false }
  end

  def validate_each(record, attribute, value)
    return unless value.present?
    options = default_options.merge(self.options)

    address = ValidEmail2::Address.new(value)

    error(record, attribute) && return unless address.valid?

    if options[:disposable]
      error(record, attribute) && return if address.disposable?
    end

    if options[:mx]
      error(record, attribute) && return unless address.valid_mx?
    end
  end

  def error(record, attribute)
    record.errors.add(attribute, options[:message] || :invalid)
  end
end
