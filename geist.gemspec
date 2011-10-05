# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require File.expand_path(File.dirname(__FILE__) + '/lib/geist/version')

Gem::Specification.new do |s|
  s.name        = 'geist'
  s.version     = Geist::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Sebastian Staudt' ]
  s.email       = [ 'koraktor@gmail.com' ]
  s.homepage    = 'https://github.com/koraktor/geist'
  s.summary     = 'A Git-backed key-value store'
  s.description = 'Geist is a Git-backed key-value store that stores Ruby objects into a Git repository.'

  s.add_dependency 'open4', '~> 1.2.0'

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'yard', '~> 0.7.2'

  s.requirements = [ 'git >= 1.6' ]

  s.files         = `git ls-files`.split("\n")
  s.require_paths = [ 'lib' ]
end
