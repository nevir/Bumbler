# frozen_string_literal: true
require './lib/bumbler/version'

Gem::Specification.new 'bumbler', Bumbler::VERSION do |s|
  s.authors     = ['Ian MacLeod']
  s.email       = ['ian@nevir.net']
  s.homepage    = 'https://github.com/nevir/Bumbler'
  s.summary = s.description = "Find slowly loading gems for your Bundler-based projects"
  s.files        = `git ls-files lib bin README.md MIT-LICENSE.md`.split("\n")
  s.executables  = ['bumbler']
  s.license      = "MIT"
  s.required_ruby_version = '>= 2.3.0'

  s.add_development_dependency "bump"
  s.add_development_dependency "maxitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop"
end
