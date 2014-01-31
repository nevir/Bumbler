require 'bundler/setup'
require 'bundler/gem_tasks'
require "rake/testtask"
require 'bump/tasks'

Rake::TestTask.new :default do |test|
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
