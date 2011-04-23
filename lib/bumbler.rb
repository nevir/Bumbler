module Bumbler
  # We can be required twice due to the command line require
  VERSION = '0.1.2' unless self.const_defined? :VERSION
  
  autoload :Hooks,    'bumbler/hooks'
  autoload :Bundler,  'bumbler/bundler'
  autoload :Progress, 'bumbler/progress'
end
