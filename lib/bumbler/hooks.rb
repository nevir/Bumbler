module Bumbler
  module Hooks
    @previous_gems = {}
    
    # Everything's a class method (we're a singleton)
    class << self
      # Inject our custom handling of require into the Kernel.
      def hook_require!
        @hooking_require = true
        
        # There are two independent require methods.  Joy!
        ::Kernel.module_eval do
          class << self
            orig_public_require = Kernel.public_method(:require)
            define_method(:require) do |path, *args|
              ::Bumbler::Hooks.handle_require(path) do
                orig_public_require.call(path, *args)
              end
            end
          end
          
          orig_instance_require = self.instance_method(:require)
          define_method(:require) do |path, *args|
            ::Bumbler::Hooks.handle_require(path) do
              orig_instance_require.bind(self).call(path, *args)
            end
          end
        end
        
        @hooking_require = nil
      end
      
      # Even better: Other gems hook require as well.  The instance method one at least.
      def watch_require!
        ::Kernel.module_eval do
          # It isn't previously defined in Kernel.  This could be a bit dangerous, though.
          def self.method_added(method_name, *args)
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
      def handle_require(path)
        # break out early if we're already handling this
        return yield if path == @previous_require
        @previous_require = path
        
        # Shortcut unless we're tracking the gem
        gem_name = Bumbler::Bundler.gem_for_require(path)
        return yield unless gem_name
        
        # Track load starts
        Bumbler::Bundler.require_started(path) unless @previous_gems[gem_name]
        @previous_gems[gem_name] = true
        
        # Let's time them
        start = Time.now.to_f
        result = yield
        require_time = (Time.now.to_f - start) * 1000 # ms
        
        Bumbler::Bundler.require_finished(path, require_time) if result
        
        return result
      end
    end
  end
end
