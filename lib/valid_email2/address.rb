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
        # Valid address needs to have a dot in the domain
        !!address.domain.match(/\./)
      else
        false
      end
    end

    def disposable?
      valid? && ValidEmail2.disposable_emails.include?(address.domain)
    end

    def blacklisted?
      valid? && ValidEmail2.blacklist.include?(address.domain)
    end

    def valid_mx?
      return false unless valid?

      mx = []

      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(address.domain, Resolv::DNS::Resource::IN::MX)
      end

      mx.any?
    end
  end
end
