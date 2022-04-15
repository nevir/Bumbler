# frozen_string_literal: true
require 'bundler/setup'
require 'maxitest/global_must'
require 'maxitest/autorun'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

module ShellHelper
  def sh(command, fail: false, keep_output: false)
    result = Bundler.with_original_env { `#{command} #{"2>&1" unless keep_output}` }
    raise "#{fail ? "SUCCESS" : "FAIL"} #{command}\n#{result}" if $?.success? == fail
    result
  end
end
