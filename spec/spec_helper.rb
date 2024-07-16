if ENV['CI']
  require 'simplecov'
  # mysql, sqlite, and pg take different routes
  # each tests different paths. This allows us to consolidate
  SimpleCov.use_merging(true)
  SimpleCov.command_name "#{SimpleCov.command_name}-#{ENV.fetch("DB", "sqlite")}"
  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
    primary_coverage :branch
  end
end

require 'bundler/setup'
require 'active_record'
require 'active_record/hash_options'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # default for rspec 4, manually set in rspec 3
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true
  config.expose_dsl_globally = false

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # not optimal, but allows tests to use short syntax ':column => gt()'
  config.include ActiveRecord::HashOptions::Helpers

  config.profile_examples = ENV["RSPEC_EXAMPLES"].to_i if ENV["RSPEC_EXAMPLES"].to_s.present?

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
