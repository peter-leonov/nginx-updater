#!/usr/bin/env ruby1.9
require 'tmpdir'

class NginxUpdater

  module Config
    NGINX_SRC_PATH = "/Users/peter/pro/nginx/"
    TMP_DIR_SUFFIX = "nginx-updater"
  end
  
  class Version < Array
    def to_s
      "#{self[0]}.#{self[1]}.#{self[2]}"
    end
    
    def url
      "http://sysoev.ru/nginx/nginx-#{self}.tar.gz"
    end
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
    
    git_checkout(git_branch)
    
    current = guess_current_nginx_version
    puts "Current version is #{current}"
    
    nxt = guess_next_version(current)
    unless nxt
      puts "Current version is the latest"
      return
    end
    
    puts "Next version is #{nxt}"
    
    tmp = "#{Dir.tmpdir}/#{Config::TMP_DIR_SUFFIX}"
    
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(tmp)
    
  end
  
  def guess_next_version v
    n = v.dup
    
    found = nil
    misses = 0
    while misses < 3
      n[2] += 1
      if check_version(n)
        return n
      end
      misses += 1
    end
    found
  end
  
  def check_version v
    puts "..checking for #{v}"
    !!`curl -sI #{v.url}`.match(/200 OK/)
  end
  
  def git_checkout branch
    system("git checkout #{branch} 2>/dev/null")
  end
  
  def guess_current_nginx_version
    source = File.read("src/core/nginx.h")
    Version.new(source.scan(/#define\s+NGINX_VERSION\s+"(\d+)\.(\d+)\.(\d+)"/)[0].map{ |v| v.to_i })
  end
  
end

exit NginxUpdater.new.run