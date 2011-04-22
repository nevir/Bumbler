# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bumbler/version"

Gem::Specification.new do |s|
  s.name        = "bumbler"
  s.version     = Bumbler::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ian MacLeod"]
  s.email       = ["ian@nevir.net"]
  s.homepage    = "https://github.com/nevir/Bumbler"
  s.summary     = %q{Track the load progress of your Bundler-based projects}
  s.description = %q{Why stare blankly at your terminal window when you can clutter it up with awesome progress bars?}

  s.rubyforge_project = "bumbler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
