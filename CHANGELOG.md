# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).



## [Unreleased]

### Fixed

- Support for ruby 2.3
- Use TravisCI as test runner for multiple ruby releases


## [0.4.1] - 2017-07-07

### Fixed

- No longer crashes if REMOTENV_URL is not set when loading


## [0.4.0] - 2017-07-07

### Added

- Extensible Adapter Framework
- HTTP Adapter
- S3 Adapter (Authed HTTP Adapter wrapper)
- Full test coverage and 4.0 GPA quality
- Ruby 2.4 support
- Rake tasks utilities for debugging integrations

### Changed

- Moved from personal account to business for official support
- Renamed from Envoku to Remotenv

### Removed

- Features are no longer a feature. Do one thing and do it well.


[Unreleased]: https://github.com/signisto/remotenv-ruby/compare/v0.4.1...HEAD
[0.4.1]: https://github.com/signisto/remotenv-ruby/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/signisto/remotenv-ruby/compare/v0.3.0...v0.4.0
