$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
Bundler.setup

require 'active_record'
require 'active_record/hash_options'
require 'minitest/autorun'
