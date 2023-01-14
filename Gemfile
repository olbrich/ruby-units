source 'https://rubygems.org'

# These are gems that are only used for local development and don't need to be included at runtime or for running tests.
# The CI process will not install them.
group :optional do
  gem 'debug', '>= 1.0.0', platform: :mri
  gem 'redcarpet', platform: :mri # redcarpet doesn't support jruby
  gem 'ruby-maven', platform: :jruby
  gem 'ruby-prof', platform: :mri
end

gemspec
