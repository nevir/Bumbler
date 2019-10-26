Bumbler
=======

Find slow loading gems in your [Bundler](http://gembundler.com/)-based projects!

Bumbler tracks how long the main require of each gem takes,
for example with `gem 'bar'` it tracks `require 'bar'`. If the gem name and the require name are different,
add `require:` manually for correct time tracking, for example `gem 'bar-foo', require: 'bar_foo'`.
This reuquire tracking can sometimes lead to false positives, because of dependencies,
for example `foo` requires `rails` which leads to `foo` being marked as slow.

For rails projects it loads `config/environment.rb`, for all others it runs `Bundler.require *Bundler.groups`.

```bash
gem install bumbler
cd project && bumbler
```

### Custom entrypoints

Add bumbler to your Gemfile
```ruby
gem 'bumbler'
```

```
RUBYOPT=-rbumbler/go bundle exec ruby -r./lib/foo.rb -e Bumbler::Stats.print_slow_items
```

### Custom threshold

Set the minimum number of milliseconds before something slow is listed. For
example, to show anything >= 10ms:

```bash
bumbler -t 10
```

### Rails: Track load-time of initializers

See how slow your app's initializers are (`./config/initializers/*`), as well as
the initializers for any engines you rely on.

```bash
bumbler --initializers
```

### Show all loaded gems

Rails:

```bash
bumbler --all
```

Ruby:

```bash
-e Bumbler::Stats.print_tracked_items
```


Development
-----------

### Rails

We don't have any integration tests with rails, so when touching rails code make sure to test it in a real app.

```Ruby
cd my-rails-app && ~/Code/tools/bumbler/bin/bumbler
```

### Release new version

`rake bump:[major|minor|patch] && rake release`


License
-------

Bumbler is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for the full
text.
