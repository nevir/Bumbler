# frozen_string_literal: true
require_relative '../test_helper'

if RUBY_VERSION.start_with?("2.7")
  describe 'Integration testing with Rails app' do
    include ShellHelper

    it 'prints simple progress' do
      output = sh("cd #{File.expand_path('fakeapp', __dir__)} && bundle install && #{Bundler.root}/bin/bumbler")
      output.must_include <<~TEXT
        ( 0/10)  rails
        ( 1/10)  sqlite3
        ( 2/10)  puma
        ( 3/10)  sass-rails
        ( 4/10)  jbuilder
        ( 5/10)  byebug
        ( 6/10)  listen
      TEXT
      output.must_match(/\d+ of 10 gems required/)
    end
  end
end
