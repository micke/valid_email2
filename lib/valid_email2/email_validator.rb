require "valid_email2/address"
require "active_model"
require "active_model/validations"

module ValidEmail2
  class EmailValidator < ActiveModel::EachValidator
    def default_options
      { regex: true, disposable: false, mx: false, disallow_subaddressing: false, multiple: false }
    end

    def validate_each(record, attribute, value)
      return unless value.present?
      options = default_options.merge(self.options)

      value_spitted = options[:multiple] ? value.split(',').map(&:strip) : [value]
      addresses = value_spitted.map { |v| ValidEmail2::Address.new(v) }

      error(record, attribute) && return unless addresses.all?(&:valid?)

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

      if options[:disposable_with_whitelist]
        error(record, attribute) && return if addresses.any? { |address| address.disposable? && !address.whitelisted? }
      end

      if options[:blacklist]
        error(record, attribute) && return if addresses.any?(&:blacklisted?)
      end

      if options[:mx]
        error(record, attribute) && return unless addresses.all?(&:valid_mx?)
      end
    end

    def error(record, attribute)
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
