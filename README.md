Geist
=====

Geist is a Git-backed key-value store written in Ruby.

## Usage

    require 'geist'

    g = Geist.new '~/some/storage/path'
    g.set :foo, 'bar'
    g.set :baz, 123
    g.set :name => 'geist', :platform => 'ruby'

    g.keys                 #=> ["foo", "name", "platform"]
    g.get :foo             #=> "bar"
    g.get :baz             #=> 123
    g.get :name, :platform #=> ["geist", "ruby"]

    g.delete :baz
    g.get :baz             #=> nil

## Internals

To be honest, the introduction was an outright fabrication. Geist is just a
Ruby API to misuse Git as a simple key-value store. Git itself is a pretty good
key-value store used to preserve blob (file), tree (directory), commit and tag
objects. A key-value store used to store versioned file histories in general.

Geist instead uses some low-level Git commands to store arbitrary Ruby objects
in a Git repository. The Ruby objects to store as values will be marshalled
into Git blob objects. These objects are referenced with lightweight Git tags
named by the given key.

Git will not double store duplicate values. Instead, the different key tags
will refer the same Git object.

## Caveats

As Geist uses Git tags as keys, only objects with a working `#to_s` method can
be used as keys. Additionally, based on Git's [ref naming rules][1], Geist
rejects keys that can't be used as Git tag names, e.g. containing non-printable
characters or backslashes.

## History

Geist was an idea for the Codebrawl contest ["Key/value stores"][2] and made it
to a honorable 6th place out of 18 contestants with a final score of 3.6.

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

 * Sebastian Staudt – koraktor(at)gmail.com

 [1]: http://www.kernel.org/pub/software/scm/git/docs/git-check-ref-format.html
 [2]: http://codebrawl.com/contests/key-value-stores
