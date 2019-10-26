# frozen_string_literal: true
# TODO: replace with ruby-progressbar dependency
module Bumbler
  module Progress
    @item_count   = 0
    @loaded_items = 0

    # registry[item_type][item_name] = {:time => 123.45}
    @registry = Hash.new { |h, k| h[k] = {} }

    class << self
      attr_reader :registry

      def register_item(type, name)
        # Build a blank key for the item
        @item_count += 1 unless @registry[type][name]

        @registry[type][name] = {}
      end

      def item_started(type, name)
        @curr_item = { type: type, name: name }

        render_progress
      end

      def item_finished(type, name, time)
        @registry[type][name] = { time: time }

        @loaded_items += 1

        @prev_item = { type: type, name: name, time: time }
        @curr_item = nil if @curr_item && @curr_item[:name] == @prev_item[:name] && @curr_item[:type] == @prev_item[:type]

        render_progress
      end

      def start!
        # No-op for now.
      end

      def tty_width
        `tput cols`.to_i || 80
      end

      def bar(width)
        inner_size = width - 2

        fill_size = [((@loaded_items / @item_count.to_f) * inner_size).to_i, inner_size].min
        fill = '#' * fill_size
        empty = ' ' * (inner_size - fill_size)

        "[#{fill}#{empty}]"
      end

      def render_progress
        # Do nothing if we don't have any items to load
        return if @item_count == 0

        # Output components:
        #   [#######################################]
        #   (##/##) <current>...   <prev> (####.##ms)
        #
        # Skip the current if there isn't enough room
        count   = format('(%s/%d) ', @loaded_items.to_s.rjust(@item_count.to_s.size), @item_count)
        current = @curr_item ? "#{@curr_item[:name]}... " : ''
        prev    = @prev_item ? format('%s (%sms)', @prev_item[:name], ('%.2f' % @prev_item[:time]).rjust(7)) : ''

        if $stdout.tty?
          width = tty_width

          print "\r\e[A\r\e[A" if @outputted_once
          @outputted_once = true

          # Align the bottom row
          space_for_current = width - (count.length + prev.length)

          # Render the progress
          puts bar(width)

          if space_for_current >= current.length
            puts count + current + prev.rjust(width - count.length - current.length)
          else
            puts count + prev.rjust(width - count.length)
          end
        elsif @curr_item
          puts format('%s %s', count, @curr_item[:name])
        end
      end
    end
  end
end
