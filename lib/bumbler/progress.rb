module Bumbler
  # Singletons are fun, yay!
  module Progress
    def self.register_item(type, name)
      # Build a blank key for the item
      unless self.registry[type][name]
        @item_count ||= 0
        @item_count  += 1
      end
      
      self.registry[type][name] = {}
    end
    
    def self.item_finished(type, name, time)
      self.registry[type][name] = {:time => time}
      
      @loaded_items ||= 0
      @loaded_items  += 1
      
      time_str = ('%.2fms' % time).rjust(9)
      self.render_progress('%s loaded %s ' % [time_str, name])
    end
    
    def self.start!
      @loaded_items ||= 0
      @item_count   ||= 0
    end
    
  private
    # registry[item_type][item_name] = {:time => 123.45}
    def self.registry
      @registry ||= Hash.new { |h,k| h[k] = {} }
    end
    
    def self.tty_width
      `tput cols`.to_i || 80
    end
    
    def self.bar
      inner_size = self.tty_width - 2
      
      fill_size = ((@loaded_items.to_f / @item_count.to_f) * inner_size).to_i
      fill  = '#' * fill_size
      empty = ' ' * (inner_size - fill_size)
      
      return "[#{fill}#{empty}]"
    end
    
    def self.render_progress(message)
      if $stdout.tty?
        print "\r\e[A\r\e[K\r\e[A" if @outputted_once
        @outputted_once = true
        
        puts self.bar
      end
      
      puts '(%s/%d) %s' % [@loaded_items.to_s.rjust(@item_count.to_s.size), @item_count, message]
    end
  end
end
