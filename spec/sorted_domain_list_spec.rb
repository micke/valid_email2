# frozen_string_literal: true

require "spec_helper"

describe ValidEmail2::SortedDomainList do
  let(:domains) { File.readlines(ValidEmail2::DISPOSABLE_FILE, chomp: true) }
  let(:list) { described_class.new(ValidEmail2::DISPOSABLE_FILE) }

  # The bisection relies on it; pull_mailchecker_emails.rb writes it so.
  it "searches a sorted file without duplicates" do
    expect(domains.each_cons(2).all? { |a, b| a.b < b.b }).to be(true)
  end

  it "finds every domain of the file" do
    expect(domains.reject { |domain| list.include?(domain) }).to be_empty
  end

  it "finds no domain missing from the file" do
    expect(%w[gmail.com example.com 0 zzzzzzzzzz.zz].select { |domain| list.include?(domain) }).to be_empty
  end
end
