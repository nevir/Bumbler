# frozen_string_literal: true
require_relative "test_helper"
require "tmpdir"

describe Bumbler do
  include ShellHelper

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir) { test.call } } }

  describe "bumbler/go" do
    it "prints simple progress without tty on ruby project" do
      write(
        "Gemfile",
        <<~RUBY
          source 'https://rubygems.org'
          gem 'fakegem', path: '#{Bundler.root}/test/fakegem'
          gem 'bumbler', path: '#{Bundler.root}'
        RUBY
      )
      write("test.rb", "require 'bumbler/go'\nBundler.require")
      result = sh "bundle exec ruby test.rb"
      result.strip.must_equal "(0/2)  fakegem\n(1/2)  bumbler"
    end

    it "includes gems that are explicitly required" do
      write(
        "Gemfile",
        <<~RUBY
          source 'https://rubygems.org'
          gem 'fakegem', path: '#{Bundler.root}/test/fakegem', require: true
          gem 'bumbler', path: '#{Bundler.root}'
        RUBY
      )
      write("test.rb", "require 'bumbler/go'\nBundler.require")
      result = sh "bundle exec ruby test.rb"
      result.strip.must_equal "(0/2)  fakegem\n(1/2)  bumbler"
    end
  end

  describe "CLI" do
    def bumbler(command = "", **args)
      sh("#{Bundler.root}/bin/bumbler #{command}", **args)
    end

    it "shows --version" do
      bumbler("--version").must_include Bumbler::VERSION
    end

    it "shows --help" do
      bumbler("bumbler --help").must_include "Bumbler"
    end

    it "fails when given arguments" do
      bumbler("bumbler help", fail: true).must_include "arguments"
    end

    it "fails without Gemfile" do
      bumbler("", fail: true).must_include "Could not locate Gemfile"
    end

    it "works with non-rails project" do
      write("Gemfile", "source 'https://rubygems.org'")
      bumbler("").must_include "0 of 0 gems required\nSlow requires:\n"
    end

    it "loads all groups for non-rails project" do
      write "Gemfile", <<-RUBY
        source 'https://rubygems.org'
        gem 'fakegem', path: '#{Bundler.root}/test/fakegem', group: :wut
      RUBY
      bumbler("").must_include "(0/1)  fakegem\n1 of 1 gems required\nSlow requires:\n"
    end

    it "fails when using initialiers flag on non-rails project" do
      write("Gemfile", "source 'https://rubygems.org'")
      bumbler("--initializers", fail: true)
    end

    describe "with simple gemfile" do
      before do
        write("Gemfile", "source 'https://rubygems.org'\ngem 'fakegem', path: '#{Bundler.root}/test/fakegem'")
        write("config/environment.rb", "require 'bundler/setup'\nrequire 'fakegem'")
      end

      it "prints simple progress without tty" do
        bumbler.strip.must_equal "(0/1)  fakegem\n1 of 1 gems required\nSlow requires:"
      end

      it "can show all" do
        bumbler("--all").strip.must_match(/^\(0\/1\)\s+fakegem\s+1 of 1 gems required\s+\d+\.\d+\s+fakegem$/m)
      end

      it "shows more with lower threshold" do
        bumbler("-t 0").strip.must_match(/^1 of 1 gems required\s+Slow requires:\s+\d+\.\d+\s+fakegem$/m)
      end
    end

    describe "with initializers" do
      it "records initializers" do
        write("Gemfile", "")
        write("config/application.rb", <<-RUBY)
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

        write("config/environment.rb", <<-RUBY)
          Rails::Engine.new.load(Rails.root + "/config/initializers/foo.rb")
          Rails::Engine.new.load(Rails.root + "/config/initializers/bar.rb")
          Rails::Initializable::Initializer.new(:baz).run(1,2,3)
          Rails::Initializable::Initializer.new(:bong).run(1,2,3)
        RUBY

        expected = <<~TEXT.strip
          0 of 0 gems required
          Slow requires:
              TIME  ./config/initializers/foo.rb
              TIME  ./config/initializers/bar.rb
              TIME  :baz
              TIME  :bong
        TEXT
        bumbler("--initializers").strip.gsub(/\d+\.\d+/, 'TIME').must_equal expected
      end
    end
  end
end
