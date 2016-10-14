# Envoku

[![Circle CI](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master.svg?style=shield)](https://circleci.com/gh/marcqualie/envoku-ruby/tree/master)
[![Test Coverage](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/coverage.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby/coverage)
[![Code Climate](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/gpa.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby)
[![Issue Count](https://codeclimate.com/github/marcqualie/envoku-ruby/badges/issue_count.svg)](https://codeclimate.com/github/marcqualie/envoku-ruby)

Configuration storage that can be loaded into your application transparently at boot-time.


## Installation

Add this line to your application's Gemfile:

``` ruby
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

``` ruby
Envoku.load
```

## Features

``` ruby
all_features = Envoku::Feature.all
feature = Envoku::Feature.new('FEATURE1')
feature.enabled? # global for all resources
feature.enabled_for?(current_user) # does current_user have this feature enabled
feature.enable_for!(current_user) # enable feature for current_user
feature.disable_for!(current_user) # disable feature for current_user
resource.feature_enabled?('FEATURE1')
resource.toggle_feature!('FEATURE1')
resource.features_enabled
```

Per-resource features are stored in Redis via the following keys:

```
(SET)  envoku:features:[feature]:[class] 123 456 789 # IDs for resource grouped by feature and class
(SET)  envoku:features:[class]:[id] FEATURE1 FEATURE2 # Features grouped by resource and ID
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcqualie/envoku-ruby.
