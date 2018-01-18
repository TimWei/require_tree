module Kernel
  def require_tree path, opt={}
    force       = opt[:force] || false
    debug       = opt[:debug] || false
    caller_file = caller_locations.first.absolute_path
    caller_path = caller_file + '/..'
    if force
      rb_files_queue = []
      parse_path_f path, caller_path, rb_files_queue
      rb_files_queue.delete caller_file
      try_and_error rb_files_queue, debug: debug
    else

    end
  end

  private
  def parse_path_f path, base, queue
    full_path = path == '.' ? "#{base}/*" : "#{base}/#{path}/*"
    Dir[full_path].each {|sym| 
      begin
        if File.directory? sym
          parse_path_f '.', sym, queue
        elsif sym =~ /\.rb$/
          queue << sym 
        end
      end
    }
  end

  def try_and_error queue, opt={}
    debug     = opt[:debug] || false
    max_count = queue.count
    loaded    = []
    queue.each_with_index do |file, i|
      begin
        require file
        loaded << file
        puts ">> #{file} loaded...   " if debug
      rescue NameError => e 
        puts ">> #{file} NameError..." if debug  
        next
      rescue LoadError => e
        puts ">> #{file} LoadError..." if debug  
        next
      end
    end 
    try_and_error(queue - loaded) if loaded.count > 0
  end
end