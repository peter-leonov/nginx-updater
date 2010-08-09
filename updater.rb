#!/usr/bin/env ruby1.9

class NginxUpdater

  module Config
    NGINX_SRC_PATH = "/Users/peter/pro/nginx/"
  end
  
  def initialize
    @branches = {"0.8" => "master"}
  end
  
  def run
    Dir.chdir(Config::NGINX_SRC_PATH)
    
    unless `git st` =~ /working directory clean/
      warn "error: working directory is not clean"
      return 1
    end
    
    @branches.each do |k, v|
      update_branch k, v
    end
    
    return 0
  end

  def update_branch nginx_branch, git_branch
    system("git checkout #{git_branch}")
    
    
  end
  
end

exit NginxUpdater.new.run