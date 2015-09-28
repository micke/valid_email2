#!/usr/bin/env ruby

require 'rubygems'
require 'pry'

require 'yaml'

require 'json'
require 'net/http'

existing_emails = YAML.load_file('vendor/disposable_emails.yml')

url = 'https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.json'
resp = Net::HTTP.get_response(URI.parse(url))

remote_emails = JSON.parse(resp.body).flatten

result_emails = (existing_emails + remote_emails).map(&:strip).uniq.sort

File.open('vendor/new_disposable_emails.yml', 'w') {|f| f.write result_emails.to_yaml }
