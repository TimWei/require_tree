module Kernel
  def require_tree path,base=Dir.pwd
    Dir["#{base}/#{path}/*"].each {|file| 
      if File.directory? file
        require_tree '.', file
      elsif file =~ /\.rb$/
        require_relative file 
      end
    }
  end
end