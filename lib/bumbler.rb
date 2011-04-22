# Do nothing unless we're in a bundle
begin
  require 'bundler'
  # This raises if there isn't a gemfile in our root
  Bundler.default_gemfile
  
  module Bumbler
    autoload :Hooks,    'bumbler/hooks'
    autoload :Bundler,  'bumbler/bundler'
    autoload :Progress, 'bumbler/progress'
    
    Hooks.hook_require!
    Hooks.watch_require!
    
    Bundler.start!
    Progress.start!
  end
  
rescue
  # Welp, if we fail, we fail.
end
