# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fileutils'

require 'open4'

# Geist is a Git-backed key-value store written in Ruby
#
# @author Sebastian Staudt
class Geist

  # Create a new Geist instance storing into the given Git repository
  #
  # @param [String] path The path of the Git repository to store objects into
  # @raise [RuntimeError] if the directory is not empty and not a Git
  #        repository
  def initialize(path)
    @path = File.expand_path path

    if !File.exist? @path
      FileUtils.mkdir_p @path
      cmd 'init'
    elsif !cmd('ls-files').success?
      raise "#{@path} is not a Git repository."
    end
  end

  # Delete the objects with the given keys from the storage
  #
  # @param [#to_s, ...] keys One or more keys where the corresponding values
  #        should be removed from the storage
  # @return [Boolean] `true` if the objects have been removed from the
  #         repository
  # @todo This does not really remove the objects from the repository but only
  #       the tags. This should also trigger Git's garbage collection to remove
  #       the objects completely.
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

  # Retrieve the objects with the given keys from the storage
  #
  # @param [#to_s, ...] keys One or more keys where the corresponding values
  #        should be loaded from the storage
  # @return [Object, Array<Object>] One or more objects that belong to the
  #         given keys
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

  # Returns all keys which have objects available in the storage
  #
  # @return [Array<String>] The keys available in the storage
  def keys
    keys = nil
    cmd 'tag -l' do |stdin, stdout|
      keys = stdout.lines.to_a.map(&:strip) if select [stdout]
    end
    keys
  end

  # Saves one ore more values into the storage
  #
  # @param [#to_s, Hash<#to_s, Object>] keys The key to use to store the value
  #        or a hash of multiple keys and values to store
  # @param [Object] value The object to store as a value (only if a single key
  #        is given)
  def set(keys, value = nil)
    keys = { keys => value } unless keys.is_a? Hash

    keys.each do |key, val|
      if key.to_s.match(/(?:[\s^~:?*\[\\]|\.\.|@\{|(?:\/|\.|\.lock)$|^$)/)
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

  # Execute a Git command in the path of the Git repository of the current
  # Geist instance
  #
  # @param [String] git_cmd The Git command to execute
  # @param [Proc] block A block that can be used to read and write to and from
  #        the Git process' STDOUT and STDIN.
  # @return [Process::Status] The exit status of the Git process
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

  # Returns the Git SHA ID of the blob where the value for the given key is
  # stored
  #
  # @param [String, #to_s] key The key for which the Git SHA ID should be
  #        returned
  # @return [String, nil] The SHA ID of the value's Git blob or `nil` if no
  #         such object exists
  def id_for(key)
    id = nil
    status = cmd "rev-parse '#{key}'" do |stdin, stdout|
      id = stdout.read.strip if select [stdout]
    end
    status.success? ? id : nil
  end

end
