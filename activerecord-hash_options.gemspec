# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/hash_options/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-hash_options"
  spec.version       = ActiveRecord::HashOptions::VERSION
  spec.authors       = ["Keenan Brock"]
  spec.email         = ["keenan@thebrocks.net"]

  spec.summary       = %q{Give ActiveRecord where hashes more power }
  spec.description   = %q{Gives ActiveRecord where hashes more power like the ability to gt or like}
  spec.homepage      = "https://github.com/kbrock/activerecord-hash_options/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  # We use appraisal to generate the gemfiles
  # but other than that, we do not use appraisal during the runtime/development time of gem
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec-core", "~>3.8.0"
  spec.add_development_dependency "rspec-expectations", "~>3.8.0"
  spec.add_development_dependency "activerecord", ">= 5.0"
  spec.add_development_dependency "erb"
end
