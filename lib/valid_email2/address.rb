require "valid_email2"
require "resolv"
require "mail"

module ValidEmail2
  class Address
    attr_accessor :address

    ALLOWED_DOMAIN_CHARACTERS_REGEX = /\A[a-z0-9\-.]+\z/i
    DEFAULT_RECIPIENT_DELIMITER = '+'.freeze

    def initialize(address)
      @parse_error = false
      @raw_address = address

      begin
        @address = Mail::Address.new(address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end

      @parse_error ||= address_contain_emoticons? @raw_address
    end

    def valid?
      return false if @parse_error

      if address.domain && address.address == @raw_address
        domain = address.domain

        domain.match(ALLOWED_DOMAIN_CHARACTERS_REGEX) &&
          # Domain needs to have at least one dot
          domain.match(/\./) &&
          # Domain may not have two consecutive dots
          !domain.match(/\.{2,}/) &&
          # Domain may not start with a dot
          !domain.match(/^\./)
      else
        false
      end
    end

    def subaddressed?
      valid? && address.local.include?(DEFAULT_RECIPIENT_DELIMITER)
    end

    def disposable?
      valid? && domain_is_in?(ValidEmail2.disposable_emails)
    end

    def whitelisted?
      domain_is_in?(ValidEmail2.whitelist)
    end

    def blacklisted?
      valid? && domain_is_in?(ValidEmail2.blacklist)
    end

    def valid_mx?
      return false unless valid?

      Resolv::DNS.open do |dns|
        return dns.getresources(address.domain, Resolv::DNS::Resource::IN::MX).size > 0 ||
               dns.getresources(address.domain, Resolv::DNS::Resource::IN::A).size > 0
      end
    end

    private

    def domain_is_in?(domain_list)
      address_domain = address.domain.downcase
      domain_list.any? { |domain|
        address_domain.end_with?(domain) && address_domain =~ /\A(?:.+\.)*?#{domain}\z/
      }
    end

    def address_contain_emoticons? email_str
      return false if email_str.nil?

      email_str.each_char.any? { |char| char.bytesize > 1 }
    end
  end
end
