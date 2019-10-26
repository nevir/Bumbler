# frozen_string_literal: true
require 'bumbler'
require 'bundler'

# This raises if there isn't a gemfile in our root
Bundler.default_gemfile
# Workaround for Ruby 2.3, see: github.com/nevir/Bumbler/issues/12
Bumbler::Bundler.name

# Kick it off
Bumbler::Hooks.hook_require!
Bumbler::Hooks.watch_require!

Bumbler::Bundler.start!
Bumbler::Progress.start!
