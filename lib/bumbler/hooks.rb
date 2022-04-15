# frozen_string_literal: true
module Bumbler
  module Hooks
    @slow_threshold = 100.0
    @started_items = {}
    @slow_requires = {}

    # Everything's a class method (we're a singleton)
    class << self
      attr_writer :slow_threshold

      attr_reader :slow_requires

      # Inject our custom handling of require into the Kernel.
      def hook_require!
        hook_instance_require!
        hook_singleton_require!
      end

      def hook_instance_require!
        @hooking_instance_require = true

        ::Kernel.module_eval do
          orig_instance_require = instance_method(:require)
          define_method(:require) do |path, *args|
            ::Bumbler::Hooks.handle_require(path) do
              orig_instance_require.bind(self).call(path, *args)
            end
          end
          private :require
        end

        @hooking_instance_require = nil
      end

      def hook_singleton_require!
        @hooking_singleton_require = true

        ::Kernel.module_eval do
          class << self
            orig_public_require = Kernel.public_method(:require)
            define_method(:require) do |path, *args|
              ::Bumbler::Hooks.handle_require(path) do
                orig_public_require.call(path, *args)
              end
            end
          end
        end

        @hooking_singleton_require = nil
      end

      # Even better: Other gems hook require as well.  The instance method one at least.
      def watch_require!
        ::Kernel.module_eval do
          # It isn't previously defined in Kernel.  This could be a bit dangerous, though.
          def self.method_added(method_name, *_args) # rubocop:disable Lint/MissingSuper
            if method_name == :require && !Bumbler::Hooks.hooking_instance_require?
              ::Bumbler::Hooks.hook_instance_require!
            end
          end

          def self.singleton_method_added(method_name, *_args) # rubocop:disable Lint/MissingSuper
            if method_name == :require && !Bumbler::Hooks.hooking_singleton_require?
              ::Bumbler::Hooks.hook_singleton_require!
            end
          end
        end
      end

      def hooking_instance_require?
        @hooking_instance_require
      end

      def hooking_singleton_require?
        @hooking_singleton_require
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
