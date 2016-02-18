# Envoku

[![Circle CI](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master.svg?style=svg)](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master)
[![codecov.io](https://codecov.io/github/marcqualie/envoku-ruby/coverage.svg?branch=master)](https://codecov.io/github/marcqualie/envoku-ruby?branch=master)

Configuration storage that can be loaded into your application transparently at boot-time.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'envoku'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install envoku


## Usage

When Envoku is loaded it automatically uses Dotenv in the background to preload and other configuration mechanisms you may have to make transitioning seamless.

### Rails

Envoku automatically pre-loads itself during `before_configuration` phase so no configuration is required.

### Plain ruby

Run the following code before you need access to the environment variables

```
Envoku.load
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcqualie/envoku-ruby.
