# frozen_string_literal: true

# Benchmark: Cold start (require) time
# Usage: ruby spec/benchmarks/cold_start.rb
#
# Measures how long it takes to require the gem and have all unit
# definitions parsed and ready. This runs in a subprocess to get a
# true cold-start measurement each iteration.

require "benchmark"

ITERATIONS = 5

puts "=== Cold Start Benchmark ==="
puts "Measuring time to `require 'ruby-units'` (#{ITERATIONS} iterations)"
puts

times = ITERATIONS.times.map do |i|
  result = Benchmark.measure do
    system("ruby", "-I", File.expand_path("../../lib", __dir__), "-e", "require 'ruby-units'")
  end
  real = result.real
  printf "  Run %d: %.4fs\n", i + 1, real
  real
end

puts
printf "  Average: %.4fs\n", times.sum / times.size
printf "  Min:     %.4fs\n", times.min
printf "  Max:     %.4fs\n", times.max
