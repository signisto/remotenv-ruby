# Remotenv

[![Gem Version](https://badge.fury.io/rb/remotenv.svg)](https://badge.fury.io/rb/remotenv)
[![Circle CI](https://circleci.com/gh/signisto/remotenv-ruby/tree/master.svg?style=shield)](https://circleci.com/gh/signisto/remotenv-ruby/tree/master)
[![Test Coverage](https://codeclimate.com/github/signisto/remotenv-ruby/badges/coverage.svg)](https://codeclimate.com/github/signisto/remotenv-ruby/coverage)
[![Code Climate](https://codeclimate.com/github/signisto/remotenv-ruby/badges/gpa.svg)](https://codeclimate.com/github/signisto/remotenv-ruby)
[![Issue Count](https://codeclimate.com/github/signisto/remotenv-ruby/badges/issue_count.svg)](https://codeclimate.com/github/signisto/remotenv-ruby)

Securely store environment variables away from your application

**WIP:** This gem is currently under active development. Until **1.0** version backwards-incompatible changes may be introduced with each **0.x** minor version.


## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'remotenv'
```

And then execute:

    $ bundle install


## Usage

When Remotenv is loaded it automatically uses Dotenv in the background to preload and other configuration mechanisms you may have to make transitioning seamless.


### Rails

Remotenv automatically pre-loads itself during `before_configuration` phase so no configuration is required.

### Sinatra

Use the plain ruby method as early as possible, before any `ENV` variables are accessed. Usually at the top of `app.rb`.


### Plain ruby

Run the following code before you need access to the environment variables

``` ruby
Remotenv.load
```


## Todo

Below are the main features that will ideally be implemented before v1.0.
Contributions welcome.

- Local caching to protect against network errors
- Ordered override behaviour for more fine grained control
- Require/Desire to aid developer knowledge of configurations
- Add `Remotenv.configure {}` functionality
- Encrypted variables


## Changelog

https://github.com/signisto/remotenv-ruby/blob/master/CHANGELOG.md


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/signisto/remotenv-ruby.
