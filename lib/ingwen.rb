module Kernel
  def require_tree path
    rb_files_queue = []  
    parse_path path, Dir.pwd, rb_files_queue
    try_and_error rb_files_queue
  end

  private
  def parse_path path, base, queue
    Dir["#{base}/#{path}/*"].each {|path| 
      begin
        if File.directory? path
          parse_path '.', path, queue
        elsif path =~ /\.rb$/
          queue << path 
        end
      end
    }
  end

  def try_and_error queue
    max_count = queue.count
    loaded = []
    queue.each_with_index do |file, i|
      begin
        require file
        loaded << file
      rescue Exception => e   
        next
      end
    end 
    try_and_error(queue - loaded) if loaded.count > 0
  end
end