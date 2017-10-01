# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories %w[lib spec]

## Uncomment to clear the screen before every task
clearing :on

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :rspec, cmd: 'bundle exec rspec' do
  require 'ostruct'

  # Generic Ruby apps
  rspec = OpenStruct.new
  rspec.spec = ->(m) { "spec/#{m}_spec.rb" }
  rspec.spec_dir = 'spec'
  rspec.spec_helper = 'spec/spec_helper.rb'

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| rspec.spec.call(m[1]) }
  watch(rspec.spec_helper)      { rspec.spec_dir }
end
