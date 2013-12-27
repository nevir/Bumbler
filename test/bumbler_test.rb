require_relative "test_helper"
require "tmpdir"

describe Bumbler do
  describe "CLI" do
    def sh(command, options={})
      result = Bundler.with_clean_env { `#{command} #{"2>&1" unless options[:keep_output]}` }
      raise "#{options[:fail] ? "SUCCESS" : "FAIL"} #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end

    around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir) { test.call } } }

    it "prints simple progress without tty" do
      File.write("Gemfile", "source 'https://rubygems.org'\ngem 'rake'\ngem 'bumbler', :path => '#{Bundler.root}'")
      File.write("test.rb", "require 'bumbler/go'\nBundler.require")
      result = sh "bundle exec ruby test.rb"
      result.strip.must_equal "(0/2)  rake\n(1/2)  bumbler"
    end
  end
end
