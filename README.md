# ValidEmail2
[![Build Status](https://travis-ci.org/lisinge/valid_email2.png?branch=master)](https://travis-ci.org/lisinge/valid_email2)
[![Gem Version](https://badge.fury.io/rb/valid_email2.png)](http://badge.fury.io/rb/valid_email2)
[![Coverage Status](https://coveralls.io/repos/lisinge/valid_email2/badge.png)](https://coveralls.io/r/lisinge/valid_email2)
[![Code Climate](https://codeclimate.com/github/lisinge/valid_email2.png)](https://codeclimate.com/github/lisinge/valid_email2)
[![Dependency Status](https://gemnasium.com/lisinge/valid_email2.png)](https://gemnasium.com/lisinge/valid_email2)
[![Stories in Ready](https://badge.waffle.io/lisinge/valid_email2.png)](http://waffle.io/lisinge/valid_email2)

Validate emails with the help of the `mail` gem instead of some clunky regexp.
Aditionally validate that the domain has a MX record.
Optionally validate against a static [list of disposable email services](vendor/disposable_emails.yml).


### Why?

There are lots of other gems and libraries that validates email adresses but most of them use some clunky regexp.
I also saw a need to be able to validate that the email address is not coming from a "disposable email" provider.

### Is it production ready?

Yes, it is used in several production apps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "valid_email2"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install valid_email2

## Usage

### Use with ActiveModel

If you just want to validate that it is a valid email address:
```ruby
class User < ActiveRecord::Base
  validates :email, presence: true, email: true
end
```

To validate that the domain has a MX record:
```ruby
validates :email, email: { mx: true }
```

To validate that the domain is not a disposable email:
```ruby
validates :email, email: { disposable: true }
```

To validate that the domain is not blacklisted (under vendor/blacklist.yml):
```ruby
validates :email, email: { blacklist: true }
```

All together:
```ruby
validates :email, email: { mx: true, disposable: true }
```

> Note that this gem will let an empty email pass through so you will need to
> add `presence: true` if you require an email

### Use without ActiveModel

```ruby
address = ValidEmail2::Address.new("lisinge@gmail.com")
address.valid? => true
address.disposable? => false
address.valid_mx? => true
```

### Test environment

If you are validating `mx` then your specs will fail without an internet connection.
It is a good idea to stub out that validation in your test environment.  
Do so by adding this in your `spec_helper`:
```ruby
config.before(:each) do
  allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
end
```

## Requirements

This gem requires Rails 3.2 or 4.0. It is tested against both versions under:
* Ruby-1.9
* Ruby-2.0
* JRuby-1.9
* JRuby-2.0
* Rubinius-1.9

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
