# frozen_string_literal:true

require "valid_email2"
require "mail"
require "valid_email2/dns"

module ValidEmail2
  class Address
    attr_accessor :address

    PROHIBITED_DOMAIN_CHARACTERS_REGEX = /[+!_\/\s'#`]/
    DEFAULT_RECIPIENT_DELIMITER = '+'
    DOT_DELIMITER = '.'

    def self.prohibited_domain_characters_regex
      @prohibited_domain_characters_regex ||= PROHIBITED_DOMAIN_CHARACTERS_REGEX
    end

    def self.prohibited_domain_characters_regex=(val)
      @prohibited_domain_characters_regex = val
    end

    def self.permitted_multibyte_characters_regex
      @permitted_multibyte_characters_regex
    end

    def self.permitted_multibyte_characters_regex=(val)
      @permitted_multibyte_characters_regex = val
    end

    def initialize(address, dns = Dns.new)
      @parse_error = false
      @raw_address = address
      @dns = dns

      begin
        @address = Mail::Address.new(address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end

      @parse_error ||= address_contain_multibyte_characters?
    end

    def valid?
      return @valid unless @valid.nil?
      return false  if @parse_error

      @valid = valid_domain? && valid_address?
    end

    def valid_domain?
      domain = address.domain
      return false if domain.nil?

      domain !~ self.class.prohibited_domain_characters_regex &&
        domain.include?('.') &&
        !domain.include?('..') &&
        !domain.start_with?('.') &&
        !domain.start_with?('-') &&
        !domain.include?('-.')
    end

    def valid_address?
      return false if address.address != @raw_address

      !address.local.include?('..') &&
        !address.local.end_with?('.') &&
        !address.local.start_with?('.')
    end

    def dotted?
      valid? && address.local.include?(DOT_DELIMITER)
    end

    def subaddressed?
      valid? && address.local.include?(DEFAULT_RECIPIENT_DELIMITER)
    end

    def disposable?
      disposable_domain? || disposable_mx_server?
    end

    def disposable_domain?
      domain_is_in?(address.domain, ValidEmail2.disposable_emails)
    end

    def allow_listed?
      domain_is_in?(address.domain, ValidEmail2.allow_list)
    end

    def deny_listed?
      valid? && domain_is_in?(address.domain, ValidEmail2.deny_list)
    end

    def valid_mx?
      return false unless valid?
      return false if null_mx?

      @dns.mx_servers(address.domain).any? || @dns.a_servers(address.domain).any?
    end

    def valid_strict_mx?
      return false unless valid?
      return false if null_mx?

      @dns.mx_servers(address.domain).any?
    end

    private

    def disposable_mx_server?
      mx_server_is_in?(ValidEmail2.disposable_emails)
    end

    # TODO: (PS) keep this for backward compatibility with the test setup described in the reamde
    def mx_server_is_in?(domain_list)
      address_domains = @dns.mx_servers(address.domain).map(&:exchange).map(&:to_s)
      domain_is_in?(address_domains, domain_list)
    end

    def domain_is_in?(address_domains, domain_list)
      Array(address_domains).any? do |address_domain|
        address_domain = address_domain.downcase
        return true if domain_list.include?(address_domain)

        tokens = address_domain.split('.')
        return false if tokens.length < 3

        # check only 6 elements deep
        2.upto(6).each do |depth|
          limited_sub_domain_part = tokens.reverse.first(depth).reverse.join('.')
          return true if domain_list.include?(limited_sub_domain_part)
        end

        false
      end
    end

    def address_contain_multibyte_characters?
      return false if @raw_address.nil?

      return false if @raw_address.ascii_only?

      @raw_address.each_char.any? { |char| char.bytesize > 1 && char !~ self.class.permitted_multibyte_characters_regex }
    end

    def null_mx?
      mx_servers = @dns.mx_servers(address.domain)
      mx_servers.length == 1 && mx_servers.first.preference == 0 && mx_servers.first.exchange.length == 0
    end
  end
end
