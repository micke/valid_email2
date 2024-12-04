$:.unshift File.expand_path("../lib",__FILE__)
require "valid_email2"

# Include and configure  benchmark
require 'rspec-benchmark'
RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
  config.default_formatter = 'doc'
end
RSpec::Benchmark.configure do |config|
  config.disable_gc = true
end

class TestModel
  include ActiveModel::Validations

  def initialize(attributes = {})
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end
end

class TestDynamicDomainModel
  def self.where(*); end

  def self.column_names
    [domain_attribute].compact
  end

  def self.exists?(hash)
    value = hash[self.domain_attribute.to_sym]
    return false if value.nil?

    existng_array = self.domain_attribute_values
    existng_array.include?(value)
  end

  def self.domain_attribute
    @domain_attribute ||= "domain"
  end

  def self.domain_attribute_values
    @domain_attribute_values ||= []
  end

  def self.domain_attribute=(new_domain_attribute)
    @domain_attribute = new_domain_attribute
    @domain_attribute_values = domain_attribute_values
  end

  def self.domain_attribute_values=(new_domain_attribute_values)
    @domain_attribute_values = new_domain_attribute_values
  end
end
