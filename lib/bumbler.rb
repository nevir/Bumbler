module Bumbler
  # We can be required twice due to the command line require
  VERSION = '0.1.3' unless self.const_defined? :VERSION
  
  autoload :Bundler,  'bumbler/bundler'
  autoload :Hooks,    'bumbler/hooks'
  autoload :Progress, 'bumbler/progress'
  autoload :Stats,    'bumbler/stats'
end
