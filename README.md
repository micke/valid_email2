# ValidEmail2
[![Build Status](https://travis-ci.org/lisinge/valid_email2.png?branch=master)](https://travis-ci.org/lisinge/valid_email2)
[![Coverage Status](https://coveralls.io/repos/lisinge/valid_email2/badge.png)](https://coveralls.io/r/lisinge/valid_email2)
[![Code Climate](https://codeclimate.com/github/lisinge/valid_email2.png)](https://codeclimate.com/github/lisinge/valid_email2)
[![Dependency Status](https://gemnasium.com/lisinge/valid_email2.png)](https://gemnasium.com/lisinge/valid_email2)

Validate emails without regexp but with the help of the `mail` gem and MX server lookup.  
Optionally validate against a static [list of disposable email domains](vendor/disposable_emails.yml).

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
  validate :email, email: true
end
```

To validate that the domain has a MX record:  
```ruby
validate :email, email: { mx: true }
```

To validate that the domain is not a disposable email:  
```ruby
validate :email, email: { disposable: true }
```

All together:  
```ruby
validate :email, email: { mx: true, disposable: true }
```

### Use without ActiveModel

```ruby
address = ValidEmail2::Address.new("lisinge@gmail.com")
address.valid? => true
address.disposable? => false
address.valid_mx? => true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
