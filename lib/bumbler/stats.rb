# frozen_string_literal: true
module Bumbler
  module Stats
    class << self
      def tracked_items
        Bumbler::Progress.registry.each do |type, items|
          puts "Stats for #{type} items:"

          items.to_a.sort_by! { |_n, d| d[:time].to_f }.each do |name, info|
            if info[:time]
              puts format('  %s  %s', ('%.2f' % info[:time]).rjust(8), name)
            else
              puts "  pending:  #{name}"
            end
          end
        end

        self
      end

      def all_slow_items
        puts "Slow requires:"
        Bumbler::Hooks.slow_requires.to_a.sort_by! { |_n, t| t }.each do |name, time|
          puts format('  %s  %s', ('%.2f' % time).rjust(8), name)
        end

        self
      end
    end
  end
end
