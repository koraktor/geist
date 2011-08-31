require 'fileutils'
require 'open4'

class Geist

  def initialize(path)
    @path = File.expand_path path

    if !File.exist? @path
      FileUtils.mkdir_p @path
      cmd 'init'
    elsif !cmd('ls-files').success?
      raise "#{@path} is not a Git repository."
    end
  end
  
  def delete(*keys)
    success = true
    
    keys.each do |key|
      if id_for(key).nil?
        success = false
      else
        cmd "tag -d #{key}"
      end
    end
    
    success
  end
  
  def get(key, *keys)
    key = [key] unless key.is_a? Array
    keys = key + keys
    values = []

    keys.each do |key|
      value = nil
      cmd "cat-file -p #{id_for key}" do |stdin, stdout|
        blob = stdout.read.strip if select [stdout]
        value = Marshal.load blob unless blob.empty?
      end
      values << value
    end

    keys.size == 1 ? values.first : values
  end

  def keys
    keys = nil
    cmd 'tag -l' do |stdin, stdout|
      keys = stdout.lines.to_a.map(&:strip) if select [stdout]
    end
    keys
  end

  def set(keys, value = nil)
    keys = { keys => value } unless keys.is_a? Hash
    
    keys.each do |key, value|
      delete key unless id_for(key).nil?

      value = Marshal.dump value
      id = nil
      cmd 'hash-object --stdin -w' do |stdin, stdout|
        stdin.write value
        stdin.close
        id = stdout.read.strip if select [stdout]
      end
      
      cmd 'mktag' do |stdin, stdout|
        stdin.puts "object #{id}"
        stdin.puts 'type blob'
        stdin.puts "tag #{key}"
        stdin.puts "tagger geist <geist@localhost> #{Time.now.strftime '%s %z'}"
        stdin.puts
        stdin.close

        id = stdout.read.strip if select [stdout]
      end

      tag = File.new "#{@path}/refs/tags/#{key}", 'w'
      tag.write id
      tag.close
    end
  end

  private

  def cmd(git_cmd, &block)
    cmd = "git --git-dir #{@path} #{git_cmd}"
    status = Open4::popen4 cmd do |pid, stdin, stdout, stderr|
      block.call stdin, stdout if block_given?
      
      stdin.close unless stdin.closed?
      stdout.close
      stderr.close
    end
    status
  end
  
  def id_for(key)
    id = nil
    status = cmd "rev-parse --verify #{key}^{}" do |stdin, stdout|
      id = stdout.read.strip if select [stdout]
    end
    status.success? ? id : nil
  end

end
