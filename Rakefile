# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

unless RUBY_ENGINE == "jruby"
  require "rake/extensiontask"

  Rake::ExtensionTask.new("ruby_units_ext") do |ext|
    ext.lib_dir = "lib/ruby_units"
    ext.ext_dir = "ext/ruby_units"
  end

  task spec: :compile
end

task default: :spec
