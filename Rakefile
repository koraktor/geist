# -*- encoding: utf-8 -*-

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'rubygems/package_task'

# Rake tasks for building the gem
spec = Gem::Specification.load('geist.gemspec')
Gem::PackageTask.new(spec) do |pkg|
end

# Check if YARD is installed
begin
  require 'yard'

  # Create a rake task `:doc to build the documentation using YARD
  YARD::Rake::YardocTask.new do |yardoc|
    yardoc.name    = 'doc'
    yardoc.files   = [ 'lib/**/*.rb', 'Changelog.md', 'LICENSE', 'README.md' ]
    yardoc.options = [ '--markup', 'markdown', '--private', '--title', 'Geist — API Documentation' ]
  end
rescue LoadError
  # Create a rake task `:doc` to show that YARD is not installed
  desc 'Generate YARD Documentation (not available)'
  task :doc do
    $stderr.puts 'You need YARD to build the documentation. Install it using `gem install yard`.'
  end
end

# Task for cleaning documentation and package directories
desc 'Clean documentation and package directories'
task :clean do
  FileUtils.rm_rf 'doc'
  FileUtils.rm_rf 'pkg'
end
