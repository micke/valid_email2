require "resolv"
require "mail"

module ValidEmail2
  class Address
    attr_accessor :address

    def initialize(address)
      @parse_error = false

      begin
        @raw_address = address
        @address = Mail::Address.new(address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end
    end

    def valid?
      return false if @parse_error

      if address.domain && address.address == @raw_address
        tree = address.send(:tree)

        # Valid address needs to have a dot in the domain
        tree.domain.dot_atom_text.elements.size > 1
      else
        false
      end
    end

    def disposable?
      valid? && ValidEmail2.disposable_emails.include?(address.domain)
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
