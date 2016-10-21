# Envoku

[![Gem Version](https://badge.fury.io/rb/envoku.svg)](https://badge.fury.io/rb/envoku)
[![Circle CI](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master.svg?style=shield)](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master)
[![Test Coverage](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/coverage.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby/coverage)
[![Code Climate](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/gpa.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby)
[![Issue Count](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/issue_count.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby)

**WIP:** This gem is currently under active development. Until **1.0** version backwards-incompatible changes may be introduced with each **0.x** minor version.

Configuration and feature management that is pre-loaded into your application at boot-time.


## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'envoku'
```

And then execute:

    $ bundle install


## Usage

When Envoku is loaded it automatically uses Dotenv in the background to preload and other configuration mechanisms you may have to make transitioning seamless.


### Rails

Envoku automatically pre-loads itself during `before_configuration` phase so no configuration is required.

### Sinatra

Use the plain ruby method as early as possible, before any `ENV` variables are accessed. Usually at the top of `app.rb`.


### Plain ruby

Run the following code before you need access to the environment variables

``` ruby
Envoku.load
```


## Features

Feature are defined as standard environment variables as YAML objects in the following format:

``` shell
ENVOKU_FEATURE_FEATURE1="description: 'Example feature', attribute1: 'something'"
```

``` ruby
all_features = Envoku::Feature.all
feature = Envoku::Feature.new('FEATURE1')
feature.enabled? # global for all resources
feature.enabled_for?(current_user) # does current_user have this feature enabled
feature.enable_for!(current_user) # enable feature for current_user
feature.disable_for!(current_user) # disable feature for current_user
feature.attributes # {"attribute1" => "something"}
feature.permitted_for?('User') # whether or not this feature is designed for a resource
resource.feature_enabled?('FEATURE1')
resource.toggle_feature!('FEATURE1')
resource.features_enabled
```

By default, all features can be used against all resources. To restrict a feature to a certain resource:

``` shell
ENVOKU_FEATURE_FEATURE1="permitted_resources: 'Organization,User'"
```

Per-resource features are stored in Redis via the following keys:

```
(SET)  envoku:features:[feature]:[class] 123 456 789 # IDs for resource grouped by feature and class
(SET)  envoku:features:[class]:[id] FEATURE1 FEATURE2 # Features grouped by resource and ID
```


## Todo

- Logging and warnings
- Show warning when toggling features for non-permitted resources
- Add `Envoku.configure {}` functionality


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcqualie/envoku-ruby.
