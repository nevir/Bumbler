# Bumbler
Why stare blankly at your terminal window when you can clutter it up with awesome progress bars?

Use Bumbler to track the load progress of your [Bundler](http://gembundler.com/)-based projects!  Maybe you'll find a slow gem or two.


## Using Bumbler

WARNING: Works only with ruby 1.9

### Step 1:

    gem install bumbler

### Step 1.5:
Add bumbler to your Gemfile if you want to use `bundle exec`

    gem 'bumbler'

### Step 2:
Add the following to your .profile, .bash_profile, .zshrc, .wtfrc or whatever shell config you use

    export RUBYOPT=-rbumbler/go

### Step 3:
Restart your terminal


## Blammo, you're bumbling with bundler and bumbler!
Run a Bundler-based command, and you should see a spiffy progress bar, such as:

    > rails c
    [#########                                                                     ]
    ( 7/59)  492.04ms loaded data_mapper 
    > Bumbler::Stats.all_slow_items  #will show you the gems which load the slowest.


And then maybe you'll also want to contribute some patches to make your favorite gems load faster.
