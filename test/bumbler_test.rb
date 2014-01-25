require_relative "test_helper"
require "tmpdir"

describe Bumbler do
  def sh(command, options={})
    result = Bundler.with_clean_env { `#{command} #{"2>&1" unless options[:keep_output]}` }
    raise "#{options[:fail] ? "SUCCESS" : "FAIL"} #{command}\n#{result}" if $?.success? == !!options[:fail]
    result
  end

  around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir) { test.call } } }

  it "prints simple progress without tty on ruby project" do
    File.write("Gemfile", "source 'https://rubygems.org'\ngem 'rake'\ngem 'bumbler', :path => '#{Bundler.root}'")
    File.write("test.rb", "require 'bumbler/go'\nBundler.require")
    result = sh "bundle exec ruby test.rb"
    result.strip.must_equal "(0/2)  rake\n(1/2)  bumbler"
  end

  describe "CLI" do
    def bumbler(command="", options={})
      sh("#{Bundler.root}/bin/bumbler #{command}", options)
    end

    it "shows --version" do
      bumbler("--version").must_include Bumbler::VERSION
    end

    it "shows --help" do
      bumbler("bumbler --help").must_include "Bumbler"
    end

    describe "with simple gemfile" do
      def structure
        File.write("Gemfile", "source 'https://rubygems.org'\ngem 'rake'")
        FileUtils.mkdir_p("config")
        File.write("config/environment.rb", "require 'bundler/setup'\nrequire 'rake'")
      end

      it "prints simple progress without tty" do
        structure
        bumbler.strip.must_equal "(0/1)  rake\nSlow requires:"
      end

      it "shows more with lower threshold" do
        structure
        bumbler("-t 0").strip.must_match /^Slow requires:\s+\d+\.\d+\s+rake$/m
      end
    end

    describe "with initializers" do
      it "records initializers" do
        File.write("Gemfile", "")
        FileUtils.mkdir_p("config")

        File.write("config/application.rb", <<-RUBY)
          $offset = 0.0
          def wait
            sleep 0.1 + $offset
            $offset += 0.01
          end

          module FakeLoad
            def load(file)
              wait
            end
          end

          module Rails
            def self.root
              "/some/root"
            end

            class Engine
              include FakeLoad
            end

            module Initializable
              class Initializer
                def initialize(name)
                  @name = name
                end

                def run(*args)
                  wait
                end
              end
            end
          end
        RUBY

        File.write("config/environment.rb", <<-RUBY)
          Rails::Engine.new.load(Rails.root + "/config/initializers/foo.rb")
          Rails::Engine.new.load(Rails.root + "/config/initializers/bar.rb")
          Rails::Initializable::Initializer.new(:baz).run(1,2,3)
          Rails::Initializable::Initializer.new(:bong).run(1,2,3)
        RUBY

        expected = <<-TEXT.gsub(/^          /, "").strip
          Slow requires:
              time  ./config/initializers/foo.rb
              time  ./config/initializers/bar.rb
              time  :baz
              time  :bong
        TEXT
        bumbler("--initializers").strip.gsub(/\d+\.\d+/, 'time').must_equal expected
      end
    end
  end
end
