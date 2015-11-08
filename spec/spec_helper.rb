require 'rubygems'
require 'bundler/setup'
Bundler.require(:development, :test)
require 'rspec/core'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
  skip_token 'nocov_19'
end

RSpec.configure do |config|
  config.order = :random
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end

require File.dirname(__FILE__) + "/../lib/ruby-units"
