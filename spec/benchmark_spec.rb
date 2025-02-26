# frozen_string_literal: true

require "spec_helper"

describe "Performance testing" do
  let(:disposable_domain) { ValidEmail2.disposable_emails.first }

  it "disposable_domain? has acceptable lookup performance" do
    address = ValidEmail2::Address.new("test@example.com")

    # preload list and check size
    expect(ValidEmail2.disposable_emails).to be_a(Set)
    expect(ValidEmail2.disposable_emails.count).to be > 30000

    # check lookup timing
    expect { address.disposable_domain? }.to perform_under(0.0001).sec.sample(10).times
  end

  it "disposable_mx_server? has acceptable lookup performance" do
    address = ValidEmail2::Address.new("test@gmail.com")

    # preload list and check size
    expect(ValidEmail2.disposable_emails).to be_a(Set)
    expect(ValidEmail2.disposable_emails.count).to be > 30000

    # check lookup timing
    expect { address.disposable_mx_server? }.to perform_under(0.0001).sec.warmup(1).times.sample(10).times
  end
end
