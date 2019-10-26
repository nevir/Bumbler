# frozen_string_literal: true
module Bumbler
  module Bundler
    class << self
      # Returns which gem a require maps to, or nil.
      def gem_for_require(path)
        read_bundler_environment if @require_map.nil?

        @require_map[path]
      end

      def require_started(path)
        gem_name = gem_for_require(path)
        return unless gem_name

        Bumbler::Progress.item_started(:bundler, gem_name)
      end

      def require_finished(path, load_time)
        read_bundler_environment if @gem_state.nil?

        # Tick it off for the gem.
        gem_name = gem_for_require(path)
        return unless gem_name

        @gem_state[gem_name][path] = true

        Bumbler::Progress.item_finished(:bundler, gem_name, load_time) if @gem_state[gem_name].values.all?
      end

      def start!
        read_bundler_environment
      end

      private

      def read_bundler_environment
        @require_map = {}
        @gem_state = {}

        ::Bundler.environment.current_dependencies.each do |spec|
          gem_name = spec.name
          @gem_state[gem_name] = {}

          # TODO: this is horrible guess-work ... we need to get the gens load-path instead
          paths =
            if !spec.autorequire || spec.autorequire == [true]
              [gem_name]
            else
              spec.autorequire
            end

          paths.each do |path|
            @require_map[path] = gem_name
            @gem_state[gem_name][path] = false
          end

          Bumbler::Progress.register_item(:bundler, gem_name)
        end
      end
    end
  end
end
