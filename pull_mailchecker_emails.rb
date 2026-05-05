#!/usr/bin/env ruby

require "yaml"

require "json"
require "net/http"
require "public_suffix"

allow_listed_emails = %w[
  onet.pl poczta.onet.pl fastmail.fm hushmail.com
  hush.ai hush.com hushmail.me naver.com qq.com example.com
  yandex.net gmx.com gmx.es webdesignspecialist.com.au vp.com
  onit.com asics.com freemail.hu 139.com mail2world.com slmail.me
  zoho.com zoho.in simplelogin.com simplelogin.fr simplelogin.co
  simplelogin.io aleeas.com slmails.com silomails.com slmail.me
  passinbox.com passfwd.com passmail.com passmail.net
  duck.com mozmail.com dralias.com 8alias.com 8shield.net
  mailinblack.com anonaddy.com anonaddy.me addy.io privaterelay.appleid.com appleid.com
  net.ua kommespaeter.de alpenjodel.de my.id web.id directbox.com embarqmail.com
]

# Subdomains under these public suffixes belong to independent institutions or
# registrants that should never be blocked wholesale. Listing a single subdomain
# (e.g. "nootopics.tulane.edu") must NOT collapse to the institution's
# registrable domain ("tulane.edu") and block every Tulane address. The check
# matches both plain forms (`edu`, `gov`, `mil`) and country-coded equivalents
# (`ac.uk`, `gov.au`, `mil.uk`, `edu.au`, etc.) by looking for any matching
# label inside the public suffix as parsed by the PSL.
INSTITUTIONAL_LABELS = %w[edu gov mil ac].freeze

def institutional_tld?(tld)
  return false if tld.nil? || tld.empty?
  tld.split(".").any? { |label| INSTITUTIONAL_LABELS.include?(label) }
end

# Returns the canonical disposable-list entry for a domain.
#
# - For institutional public suffixes (.edu/.gov/.mil/.ac.*/...), the original
#   domain is preserved verbatim. These suffixes are shared namespaces; a
#   single bad subdomain must not block the whole institution.
# - For all other domains, returns the registrable domain (the public suffix
#   plus one label, e.g. "fastee.com" for "mail.fastee.com"). This preserves
#   the historical behavior of catching all subdomains of a disposable host.
# - On parse failure, falls back to the original input rather than dropping it.
def normalize(domain)
  parsed = PublicSuffix.parse(domain)
  institutional_tld?(parsed.tld) ? domain : parsed.domain
rescue PublicSuffix::DomainInvalid, PublicSuffix::DomainNotAllowed
  domain
end

existing_emails = File.open("config/disposable_email_domains.txt") { |f| f.read.split("\n") }

remote_emails = [
  "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.txt",
  "https://raw.githubusercontent.com/disposable/disposable-email-domains/master/domains.txt"
].flat_map do |url|
  resp = Net::HTTP.get_response(URI.parse(url))

  resp.body.split("\n").flatten.map(&:downcase)
end

# One-time cleanup of legacy over-collapse artifacts. Prior to this script's
# PSL-based normalization, a single subdomain like "nootopics.tulane.edu" was
# truncated to "tulane.edu" and that 2-segment institutional entry was
# accumulated in the shipped list. Remove any 2-segment institutional entry
# from the existing list that is not present in any current upstream source —
# those are over-collapse artifacts that should never have blocked an entire
# institution. Entries that ARE in upstream are preserved (someone explicitly
# listed them, however unlikely).
upstream_set = remote_emails.map(&:strip).reject(&:empty?).to_set
existing_emails = existing_emails.reject do |line|
  domain = line.strip.downcase
  next false if domain.empty? || upstream_set.include?(domain)
  parts = domain.split(".")
  parts.size == 2 && INSTITUTIONAL_LABELS.include?(parts.last)
end

result_emails = (existing_emails + remote_emails).map(&:strip).reject(&:empty?) - allow_listed_emails
result_emails = result_emails.map { |line| normalize(line.chomp) }.uniq.sort

File.open("config/disposable_email_domains.txt", "w") { |f| f.puts(result_emails) }
