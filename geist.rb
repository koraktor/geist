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
        cmd "tag -d '#{key}'"
      end
    end

    success
  end

  def get(*keys)
    return nil if keys.empty?

    values = []
    keys.each do |key|
      value = nil
      status = cmd "show '#{key}'" do |stdin, stdout|
        if select [stdout]
          blob = stdout.read.strip
          value = Marshal.load blob unless blob.empty?
        end
      end
      values << (status.success? ? value : nil)
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

    keys.each do |key, val|
      if key.to_s.match /(?:[\W\s^~:?*\[\\]|\.\.|@\{|(?:\/|\.|\.lock)$|^$)/
        warn "Warning: Invalid key '#{key}'"
        return
      end

      delete key unless id_for(key).nil?

      id = nil
      cmd 'hash-object --stdin -w' do |stdin, stdout|
        stdin.write Marshal.dump(val)
        stdin.close
        id = stdout.read.strip if select [stdout]
      end

      cmd "tag -f '#{key}' #{id}"
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
    status = cmd "rev-parse '#{key}'" do |stdin, stdout|
      id = stdout.read.strip if select [stdout]
    end
    status.success? ? id : nil
  end

end
