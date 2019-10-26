# frozen_string_literal: true
module Bumbler
  module Bundler
    class << self
      # Returns which gem a require maps to, or nil.
      def gem_for_require(path)
        @require_map[path]
      end

      def require_started(gem_name)
        Bumbler::Progress.item_started(gem_name)
      end

      def require_finished(gem_name, path, time)
        @gem_state[gem_name][path] = true
        if @gem_state[gem_name].values.all?
          Bumbler::Progress.item_finished(gem_name, time)
        end
      end

      def read_bundler_environment
        @require_map = {}
        @gem_state = {}

        ::Bundler.environment.current_dependencies.each do |spec|
          gem_name = spec.name
          @gem_state[gem_name] = {}

          # TODO: this is horrible guess-work ... we need to get the gems load-path instead
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

          Bumbler::Progress.register_item(gem_name)
        end
      end
    end
  end
end
