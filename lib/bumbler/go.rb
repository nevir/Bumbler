require 'bumbler'

# Do nothing unless we're in a bundle
begin
  require 'bundler'
  # This raises if there isn't a gemfile in our root
  Bundler.default_gemfile
  # Workaround for Ruby 2.3, see: github.com/nevir/Bumbler/issues/12
  Bumbler::Bundler

  # Kick it off
  Bumbler::Hooks.hook_require!
  Bumbler::Hooks.watch_require!

  Bumbler::Bundler.start!
  Bumbler::Progress.start!

rescue
  # Welp, if we fail, we fail.
end
