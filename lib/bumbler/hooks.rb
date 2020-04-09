# frozen_string_literal: true
module Bumbler
  module Hooks
    @slow_threshold = 100.0
    @started_items = {}
    @slow_requires = {}

    module RequireLogger
      def require(path, *args)
        ::Bumbler::Hooks.handle_require(path) { super }
      end
    end

    # Everything's a class method (we're a singleton)
    class << self
      attr_writer :slow_threshold

      attr_reader :slow_requires

      # Inject our custom handling of require into the Kernel.
      def hook_require!
        @hooking_require = true

        # There are two independent require methods.  Joy!
        ::Kernel.prepend RequireLogger
        (class << ::Kernel; self; end).prepend RequireLogger

        @hooking_require = nil
      end

      # Even better: Other gems hook require as well.  The instance method one at least.
      def watch_require!
        ::Kernel.module_eval do
          # It isn't previously defined in Kernel.  This could be a bit dangerous, though.
          def self.method_added(method_name, *_args)
            if method_name == :require && !::Bumbler::Hooks.hooking_require?
              # Fix those hooks.
              ::Bumbler::Hooks.hook_require!
            end
          end
        end
      end

      def hooking_require?
        @hooking_require
      end

      # Actually do something about a require here.
      def handle_require(path, &block)
        # break out early if we're already handling the path
        return yield if path == @previous_require
        @previous_require = path

        # ignore untracked gem
        return yield unless (gem_name = Bumbler::Bundler.gem_for_require(path))

        # track load starts
        Bumbler::Bundler.require_started(gem_name) unless @started_items[gem_name]
        @started_items[gem_name] = true

        time, result = benchmark(path, &block)

        # TODO: for items with multiple paths we need to add the times
        Bumbler::Bundler.require_finished(gem_name, path, time) if result

        result
      end

      def benchmark(key)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = yield
        time = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000 # ms
        @slow_requires[key] = time if time > @slow_threshold
        [time, result]
      end
    end
  end
end
