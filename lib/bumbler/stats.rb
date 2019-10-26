# frozen_string_literal: true
module Bumbler
  module Stats
    class << self
      def print_tracked_items
        Bumbler::Progress.registry.sort_by { |_n, time| time.to_f }.each do |name, time|
          if time
            puts format('  %s  %s', ('%.2f' % time).rjust(8), name)
          else
            puts "  pending:  #{name}"
          end
        end

        self
      end

      def print_slow_items
        puts "Slow requires:"
        Bumbler::Hooks.slow_requires.to_a.sort_by! { |_n, t| t }.each do |name, time|
          puts format('  %s  %s', ('%.2f' % time).rjust(8), name)
        end

        self
      end
    end
  end
end
