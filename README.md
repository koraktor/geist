Geist
=====

Geist is a Git-backed key-value store written in Ruby. You may call it "Git
Explicit Item Storage Tool" if you really want too.

## Usage

```ruby
require 'geist'

g = Geist.new '~/some/storage/path'
g.set :foo, 'bar'
g.set :baz, 123
g.set :name => 'geist', :platform => 'ruby'
g.delete :baz

g.keys                 #=> ["foo", "name", "platform"]
g.get :foo             #=> "bar"
g.get :baz             #=> nil
g.get :name, :platform #=> ["geist", "ruby"]
```

## Internals

The Ruby objects to store as values will be marshalled into Git blob objects.
These objects are referenced with lightweight Git tags named by the given key.

Git will not double store duplicate values. Instead, the different key tags
will refer the same Git object.

## Caveats

Based on Git's [ref naming rules][1] Geist rejects keys that can't be used as
Git tag names, e.g. containing non-printable characters or backslashes.

 [1]: http://www.kernel.org/pub/software/scm/git/docs/git-check-ref-format.html
 
## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

 * Sebastian Staudt – koraktor(at)gmail.com
