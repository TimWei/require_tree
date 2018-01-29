
module Kernel
  def require_tree path, opt={}
    force       = opt[:force] || false
    debug       = opt[:debug] || false
    caller_file = caller_locations.first.absolute_path
    caller_path = caller_file + '/..'
    rb_files_queue = []
    parse_path_f path: path, base: caller_path, queue: rb_files_queue, force: force
    rb_files_queue.delete caller_file
    try_and_error rb_files_queue, debug: debug
  end

  private
  def parse_path_f opt={}
    path  = opt[:path]
    base  = opt[:base]
    queue = opt[:queue]
    force = opt[:force]
    full_path = path == '.' ? "#{base}/*" : "#{base}/#{path}/*"
    if force
      Dir[full_path].each {|sym| 
        begin
          if File.directory? sym
            parse_path_f path: '.', base: sym, queue: queue
          elsif sym =~ /\.rb$/
            queue << sym 
          end
        end
      }
    else
      folders   = []
      Dir[full_path].each {|sym| 
        begin
          if File.directory? sym
            folders << sym
          elsif sym =~ /\.rb$/
            queue << sym 
          end
        end
      }
      folders.each {|sym| 
        parse_path_f path: '.', base: sym, queue: queue
      }
    end
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