# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "valid_email2/version"

Gem::Specification.new do |spec|
  spec.name          = "valid_email2"
  spec.version       = ValidEmail2::VERSION
  spec.authors       = ["Micke Lisinge"]
  spec.email         = ["hi@micke.me"]
  spec.description   = %q{ActiveModel validation for email. Including MX lookup and disposable email deny list}
  spec.summary       = %q{ActiveModel validation for email. Including MX lookup and disposable email deny list}
  spec.homepage      = "https://github.com/micke/valid_email2"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "securerandom", "0.3.1" # https://github.com/micke/valid_email2/actions/runs/13325070756/job/37216488894
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec-benchmark", "~> 0.6"
  spec.add_development_dependency "net-smtp"
  spec.add_development_dependency "debug"
  spec.add_runtime_dependency "mail", "~> 2.5"
  spec.add_runtime_dependency "activemodel", ">= 6.0"
end
