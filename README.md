Bumbler
=======

Why stare blankly at your terminal window when you can clutter it up with
awesome progress bars?

Use Bumbler to track the load progress of your
[Bundler](http://gembundler.com/)-based projects!  Maybe you'll find a slow gem
or two.

```bash
gem install bumbler
```

Simple
------

```bash
cd rails-project && bumbler
```


Detailed usage for non-Rails projects
-------------------------------------

### Step 1:

Add bumbler to your Gemfile if you want to use `bundle exec`

```ruby
gem 'bumbler'
```

### Step 2:

Add the following to your .profile, .bash_profile, .zshrc, .wtfrc or whatever
shell config you use

```bash
export RUBYOPT=-rbumbler/go
```

### Step 3:

Restart your terminal


Blammo, you're bumbling with bundler and bumbler!
-------------------------------------------------

Run a Bundler-based command, and you should see a spiffy progress bar, such as:

```
> rails c
[#########                                                                     ]
( 7/59)  492.04ms loaded data_mapper
> Bumbler::Stats.all_slow_items  #will show you the gems which load the slowest.
```

And then maybe you'll also want to contribute some patches to make your favorite
gems load faster.


Bonus features
--------------

### Custom threshold

Set the mininum number of miliseconds before something slow is listed. For
example, to show anything >= 10ms:

```bash
bumbler -t 10
```

### Track load-time of Rails initializers

See how slow your app's initializers are (`./config/initializers/*`), as well as
the initializers for any engines you rely on.

```bash
bumbler --initializers
```

### Show all loaded gems

```bash
bumbler --all
```


Development
-----------

We don't have any integration tests with rails, so when touch rails code make sure to test it in a real app.

```Ruby
gem 'bumbler', path: '~/Code/tools/bumbler'
```

Release new version
-------------------

`rake bump:[major|minor|patch] && rake release`


License
-------

Bumbler is MIT licensed. [See the accompanying file](MIT-LICENSE.md) for the full
text.
