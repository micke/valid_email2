require "valid_email2"
require "resolv"
require "mail"

module ValidEmail2
  class Address
    attr_accessor :address

    def initialize(address)
      @parse_error = false
      @raw_address = address

      begin
        @address = Mail::Address.new(address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end
    end

    def valid?
      return false if @parse_error

      if address.domain && address.address == @raw_address
        domain = address.domain
        # Valid address needs to have a dot in the domain but not start with a dot
        !!domain.match(/\./) && !domain.match(/\.{2,}/) && !domain.match(/^\./)
      else
        false
      end
    end

    def disposable?
      valid? && domain_is_in?(ValidEmail2.disposable_emails)
    end

    def blacklisted?
      valid? && domain_is_in?(ValidEmail2.blacklist)
    end

    def valid_mx?
      return false unless valid?

      mx = []

      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(address.domain, Resolv::DNS::Resource::IN::MX)
      end

      mx.any?
    end

    private

    def domain_is_in?(domain_list)
      address_domain = address.domain.downcase
      domain_list.any? { |domain|
        address_domain.end_with?(domain) && address_domain =~ /\A(?:.+\.)*?#{domain}\z/
      }
    end
  end
end
