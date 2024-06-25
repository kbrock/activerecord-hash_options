require "logger"
require "active_record"
require "erb"

class Database
  attr_accessor :dirname
  attr_writer :adapter

  def initialize
    @dirname = "#{File.dirname(__FILE__)}/../db"
  end

  def adapter
    ENV['DB'] = "sqlite3" if ENV['DB'] == "sqlite"
    ENV['DB'] = "mysql2"  if ENV['DB'] == "mysql"
    ENV['DB'] ||= "sqlite3"
  end

  def setup
    if defined?(I18n)
      I18n.enforce_available_locales = false if I18n.respond_to?(:enforce_available_locales=)
      # I18n.fallbacks = [I18n.default_locale] if I18n.respond_to?(:fallbacks=)
    end
    log = Logger.new($stderr)
    # future / developer: may want to introduce an environment variable for help here
    # log = Logger.new('db.log')
    # log.level = Logger::Severity::DEBUG
    log.level = Logger::Severity::UNKNOWN
    ActiveRecord::Base.logger = log

    self
  end

  def migrate
    ActiveRecord::Migration.verbose = false

    config_contents = ERB.new(File.read("#{dirname}/database.yml")).result
    ActiveRecord::Base.configurations = all_config =
      if YAML.respond_to?(:safe_load)
        YAML.safe_load(config_contents, :aliases => true)
      else
        YAML.load(config_contents) # rubocop:disable Security/YAMLLoad
      end
    config = all_config[adapter]
    if config.blank?
      warn "", "", "ERROR: Could not find '#{adapter}' in database.yml"
      warn "Pick from: #{all_config.keys.join(", ")}", "", ""
      exit(1)
    end
    if ActiveRecord::VERSION::MAJOR >= 6
      ActiveRecord::Base.establish_connection(**config)
    else
      ActiveRecord::Base.establish_connection config
    end

    ActiveRecord::HashOptions.detect(ActiveRecord::Base.connection, adapter)

    puts "database settings (#{adapter}):", ActiveRecord::HashOptions.settings.inspect

    require "#{dirname}/schema"
    require "#{dirname}/models"

    self
  end
end

Database.new.setup.migrate
