#!/usr/bin/env ruby

require "yaml"

require "json"
require "net/http"

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

existing_emails = File.open("config/disposable_email_domains.txt") { |f| f.read.split("\n") }

remote_emails = [
  "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.txt",
  "https://raw.githubusercontent.com/disposable/disposable-email-domains/master/domains.txt"
].flat_map do |url|
  resp = Net::HTTP.get_response(URI.parse(url))

  resp.body.split("\n").flatten
end

deny_listed_tlds = %w[me ml id]

result_emails = (existing_emails + remote_emails).map(&:strip) - allow_listed_emails
result_emails = result_emails.map do |line|
  ts = line.chomp.split(".")
  if ts.last.size == 2 && !deny_listed_tlds.include?(ts.last)
    ts.last(3).join(".")
  else
    ts.last(2).join(".")
  end
end.uniq.sort

File.open("config/disposable_email_domains.txt", "w") { |f| f.puts(result_emails) }
