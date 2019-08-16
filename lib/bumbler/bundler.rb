module Bumbler
  module Bundler
    class << self
      # Returns which gem a require maps to, or nil.
      def gem_for_require(path)
        self.read_bundler_environment if @require_map.nil?
        
        return @require_map[path]
      end
      
      def require_started(path)
        gem_name = self.gem_for_require(path)
        return unless gem_name
        
        Bumbler::Progress.item_started(:bundler, gem_name)
      end
      
      def require_finished(path, load_time)
        self.read_bundler_environment if @gem_state.nil?
        
        # Tick it off for the gem.
        gem_name = self.gem_for_require(path)
        return unless gem_name
        
        @gem_state[gem_name][path] = true
        
        if @gem_state[gem_name].values.all?
          Bumbler::Progress.item_finished(:bundler, gem_name, load_time)
        end
      end
      
      def start!
        self.read_bundler_environment
      end
      
      def read_bundler_environment
        @require_map = {}
        @gem_state = {}
        
        ::Bundler.environment.current_dependencies.each do |spec|
          @gem_state[spec.name] = {}
          
          Array(spec.autorequire || spec.name).each do |path|
            # Handle explicitly required gems
            path = spec.name if path == true
            
            @require_map[path] = spec.name
            @gem_state[spec.name][path] = false
          end
          
          Bumbler::Progress.register_item(:bundler, spec.name)
        end
      end
    end
  end
end
