require 'rubygems'
require 'bundler'
Bundler.setup(:development)
require 'rspec/core'
require 'rspec/its'

# Initiate code coverage generation when needed
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/test/"
    skip_token "nocov_19"
  end if ENV['COVERAGE']
rescue LoadError
end
