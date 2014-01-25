require File.expand_path('../lib/bumbler/version', __FILE__)

Gem::Specification.new 'bumbler', Bumbler::VERSION do |s|
  s.authors     = ['Ian MacLeod']
  s.email       = ['ian@nevir.net']
  s.homepage    = 'https://github.com/nevir/Bumbler'
  s.summary     = %q{Track the load progress of your Bundler-based projects}
  s.description = %q{Why stare blankly at your terminal window when you can clutter it up with awesome progress bars?}
  s.files        = `git ls-files lib bin`.split("\n")
  s.executables  = ['bumbler']
  s.license      = "MIT"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-rg"
  s.add_development_dependency "minitest-around"
end
