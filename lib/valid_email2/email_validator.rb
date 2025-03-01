require "valid_email2/address"
require "logger" # Fix concurrent-ruby removing logger dependency which Rails itself does not have
require "active_model"
require "active_model/validations"

module ValidEmail2
  class EmailValidator < ActiveModel::EachValidator
    def default_options
      { disposable: false, mx: false, strict_mx: false, disallow_subaddressing: false, multiple: false, dns_timeout: 5, dns_nameserver: nil }
    end

    def validate_each(record, attribute, value)
      return unless value.present?
      options = default_options.merge(self.options)

      dns = ValidEmail2::Dns.new(options[:dns_timeout], options[:dns_nameserver])
      addresses = sanitized_values(value).map { |v| ValidEmail2::Address.new(v, dns) }

      error(record, attribute) && return unless addresses.all?(&:valid?)

      if options[:disallow_friendly]
        error(record, attribute) && return if addresses.any?(&:friendly?)
      end

      if options[:disallow_dotted]
        error(record, attribute) && return if addresses.any?(&:dotted?)
      end

      if options[:disallow_subaddressing]
        error(record, attribute) && return if addresses.any?(&:subaddressed?)
      end

      if options[:disposable]
        error(record, attribute) && return if addresses.any?(&:disposable?)
      end

      if options[:disposable_domain]
        error(record, attribute) && return if addresses.any?(&:disposable_domain?)
      end

      if options[:disposable_with_allow_list]
        error(record, attribute) && return if addresses.any? { |address| address.disposable? && !address.allow_listed? }
      end

      if options[:disposable_domain_with_allow_list]
        error(record, attribute) && return if addresses.any? { |address| address.disposable_domain? && !address.allow_listed? }
      end

      if options[:deny_list]
        error(record, attribute) && return if addresses.any?(&:deny_listed?)
      end

      if options[:mx]
        error(record, attribute) && return unless addresses.all?(&:valid_mx?)
      end

      if options[:strict_mx]
        error(record, attribute) && return unless addresses.all?(&:valid_strict_mx?)
      end
    end

    def sanitized_values(input)
      options = default_options.merge(self.options)

      if options[:multiple]
        email_list = input.is_a?(Array) ? input : input.split(',').map(&:strip)
      else
        email_list = [input]
      end

      email_list.reject(&:empty?)
    end

    def error(record, attribute)
      message = options[:message].respond_to?(:call) ? options[:message].call : options[:message]

      record.errors.add(attribute, message || :invalid)
    end
  end
end
