# frozen_string_literal: true
require 'bundler/setup'
require 'bundler/gem_tasks'
require "rake/testtask"
require 'bump/tasks'

Rake::TestTask.new :test do |test|
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :rubocop do
  sh "rubocop"
end

task default: [:test, :rubocop]
