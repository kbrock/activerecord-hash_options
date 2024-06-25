# coding: utf-8

require_relative 'lib/active_record/hash_options/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-hash_options"
  spec.version       = ActiveRecord::HashOptions::VERSION
  spec.authors       = ["Keenan Brock"]
  spec.email         = ["keenan@thebrocks.net"]

  spec.summary       = 'Give ActiveRecord where hashes more power '
  spec.description   = 'Gives ActiveRecord where hashes more power like the ability to gt or like'
  spec.homepage      = "https://github.com/kbrock/activerecord-hash_options/"
  spec.license       = "MIT"

  spec.metadata      = {
    'rubygems_mfa_required' => 'true'
  }

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  # no real ruby requirements
  spec.required_ruby_version = ">= 2.6"

  spec.add_development_dependency "activerecord", ">= 5.0"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "erb"
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec-core", "~>3.8.0"
  spec.add_development_dependency "rspec-expectations", "~>3.8.0"
  spec.add_development_dependency "simplecov", ">= 0.21.2"
end
