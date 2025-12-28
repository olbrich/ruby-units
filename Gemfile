# frozen_string_literal: true

source "https://rubygems.org"

# These are gems that are only used for local development and don't need to be included at runtime or for running tests.
# The CI process will not install them.
group :optional do
  gem "debug", ">= 1.0.0", platform: :mri
  gem "gem-ctags"
  gem "guard-rspec"
  gem "pry"
  gem "redcarpet", platform: :mri # redcarpet doesn't support jruby
  gem "reek"
  gem "ruby-lsp"
  gem "ruby-maven", platform: :jruby
  gem "ruby-prof", platform: :mri
  gem "simplecov-html"
  gem "solargraph"
  gem "terminal-notifier"
  gem "terminal-notifier-guard"
  gem "webrick"
  eval_gemfile("Gemfile.qlty")
end

gem "bigdecimal"
gem "rake"
gem "rspec", "~> 3.0"
gem "simplecov"
gem "yard"

gemspec
