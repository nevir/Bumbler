# frozen_string_literal: true
module IntegrationTest
  class << self
    def describe(description, version_requirement, &block)
      return false unless runnable?(version_requirement)
      Kernel.describe(description, &block)
    end

    def runnable?(version_requirement)
      Gem::Dependency.new('', version_requirement).match?('', RUBY_VERSION)
    end
  end
end
