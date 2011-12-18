require 'rubygems'
require 'bundler'
Bundler.setup(:development)
require 'rspec/core'
begin
  require 'simplecov'
  SimpleCov.start if ENV['SIMPLECOV']
rescue LoadError
end
require File.dirname(__FILE__) + "/../lib/ruby-units"
