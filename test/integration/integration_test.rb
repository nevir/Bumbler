# frozen_string_literal: true
require_relative '../test_helper'
require_relative 'integration_helper'

IntegrationTest.describe 'Integration testing with Rails app', '>= 2.5.3' do
  include ShellHelper

  RAILS_APP_PATH = File.expand_path('fakeapp', __dir__).freeze

  before(:all) do
    Dir.chdir(RAILS_APP_PATH) { sh('bundle install') }
  end

  around do |test|
    Dir.chdir(RAILS_APP_PATH) { test.call }
  end

  it 'prints simple progress' do
    output = sh("#{Bundler.root}/bin/bumbler")
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
